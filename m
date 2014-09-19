From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Fri, 19 Sep 2014 13:57:01 -0400
Message-ID: <541C6E6D.9000109@mojatatu.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:51739 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756626AbaISR5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 13:57:05 -0400
Received: by mail-ie0-f170.google.com with SMTP id x19so1100438ier.29
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 10:57:04 -0700 (PDT)
In-Reply-To: <20140919154946.GH1980@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/14 11:49, Jiri Pirko wrote:
> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com wrote:

>> Is this just a temporary test tool? Otherwise i dont see reason
>> for its existence (or the API that it feeds on).
>
> Please read the conversation I had with Pravin and Jesse in v1 thread.
> Long story short they like to have the api separated from ovs datapath
> so ovs daemon can use it to directly communicate with driver. Also John
> Fastabend requested a way to work with driver flows without using ovs ->
> that was the original reason I created switchdev genl api.
>
> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
> will use directly switchdev genl api.
>
> I hope I cleared this out.
>

It is - thanks Jiri.

cheers,
jamal
