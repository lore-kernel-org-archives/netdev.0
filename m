From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 10:17:02 +0200
Message-ID: <20140920081702.GF1821@nanopsycho.orion>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, edumazet@google.com,
	sfeldma@cumulusnetworks.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33890 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaITIRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 04:17:05 -0400
Received: by mail-wg0-f47.google.com with SMTP id y10so704525wgg.18
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 01:17:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <541CAB9A.3040100@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 20, 2014 at 12:18:02AM CEST, jhs@mojatatu.com wrote:
>On 09/19/14 18:12, John Fastabend wrote:
>>On 09/19/2014 10:57 AM, Jamal Hadi Salim wrote:
>>>On 09/19/14 11:49, Jiri Pirko wrote:
>>>>Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:
>>>
>>>>>Is this just a temporary test tool? Otherwise i dont see reason
>>>>>for its existence (or the API that it feeds on).
>>>>
>>>>Please read the conversation I had with Pravin and Jesse in v1 thread.
>>>>Long story short they like to have the api separated from ovs datapath
>>>>so ovs daemon can use it to directly communicate with driver. Also John
>>>>Fastabend requested a way to work with driver flows without using ovs ->
>>>>that was the original reason I created switchdev genl api.
>>>>
>>>>Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
>>>>will use directly switchdev genl api.
>>>>
>>>>I hope I cleared this out.
>>>>
>>>
>>>It is - thanks Jiri.
>>>
>>>cheers,
>>>jamal
>>
>>Hi Jiri,
>>
>>I was considering a slightly different approach where the
>>device would report via netlink the fields/actions it
>>supported rather than creating pre-defined enums for every
>>possible key.
>>
>>I already need to have an API to report fields/matches
>>that are being supported why not have the device report
>>the headers as header fields (len, offset) and the
>>associated parse graph the hardware uses? Vendors should
>>have this already to describe/design their real hardware.
>>
>>As always its better to have code and when I get some
>>time I'll try to write it up. Maybe its just a separate
>>classifier although I don't actually want two hardware
>>flow APIs.
>>
>>I see you dropped the RFC tag are you proposing we include
>>this now?
>>
>
>
>Actually I just realized i missed something very basic that
>Jiri said. I think i understand the tool being there for testing
>but i am assumed the same about the genlink api.
>Jiri, are you saying that genlink api is there to
>stay?

Yes, that I say. It is needed for flow manipulation, because such api does
not exist. As I stated earlier, I do not want to use switchdev genl for
anything other than flow manipulation.

>
>cheers,
>jamal
