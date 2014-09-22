From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 09:53:37 +0200
Message-ID: <20140922075337.GA1828@nanopsycho.orion>
References: <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541C6E6D.9000109@mojatatu.com>
 <541CAA3C.5080105@intel.com>
 <541CAB9A.3040100@mojatatu.com>
 <20140920081702.GF1821@nanopsycho.orion>
 <541D54BA.6070709@mojatatu.com>
 <20140920110121.GB29419@casper.infradead.org>
 <541D65CE.7080108@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
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
Received: from mail-we0-f178.google.com ([74.125.82.178]:35642 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbaIVHxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 03:53:39 -0400
Received: by mail-we0-f178.google.com with SMTP id t60so2418824wes.23
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 00:53:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <541D65CE.7080108@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 20, 2014 at 01:32:30PM CEST, jhs@mojatatu.com wrote:
>On 09/20/14 07:01, Thomas Graf wrote:
>
>>Nothing speaks against having such a tc classifier. In fact, having
>>the interface consist of only an embedded Netlink attribute structure
>>would allow for such a classifier in a very straight forward way.
>>
>>That doesn't mean everybody should be forced to use the stateful
>>tc interface.
>>
>
>
>Agreed. The response was to Jiri's strange statement that now that
>he cant use OVS, there is no such api. I point to tc as very capable of
>such usage.

Jamal, would you please give us some examples on how to use tc to work
with flows? I have a feeling that you see something other people does not.
Lets get on the same page now.
Thanks.


>
>>No need for false accusations here. Nobody ever mentioned vendor SDKs.
>>
>
>I am sorry to have tied the two together. Maybe not OVS but the approach
>described is heaven for vendor SDKs.
>
>>The statement was that the requirement of deriving hardware flows from
>>software flows *in the kernel* is not flexible enough for the future
>>for reasons such as:
>>
>>1) The OVS software data path might be based on eBPF in the future and
>>    it is unclear how we could derive hardware flows from that
>>    transparently.
>>
>
>Who says you cant put BPF in hardware?
>And why is OVS defining how BPF should evolve or how it should be used?
>
>>2) Depending on hardware capabilities. Hardware flows might need to be
>>    assisted by software flow counterparts and it is believed that it
>>    is the wrong approach to push all the necessary context for the
>>    decision down into the kernel. This can be argued about and I don't
>>    feel strongly either way.
>>
>
>Pointing to the current FDB offload: You can select to bypass
>and not use s/ware.
>
>cheers,
>jamal
