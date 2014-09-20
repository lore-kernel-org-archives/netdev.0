From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 07:32:30 -0400
Message-ID: <541D65CE.7080108@mojatatu.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541C6E6D.9000109@mojatatu.com> <541CAA3C.5080105@intel.com> <541CAB9A.3040100@mojatatu.com> <20140920081702.GF1821@nanopsycho.orion> <541D54BA.6070709@mojatatu.com> <20140920110121.GB29419@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:50835 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbaITLcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 07:32:35 -0400
Received: by mail-ie0-f176.google.com with SMTP id ar1so5063171iec.21
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 04:32:34 -0700 (PDT)
In-Reply-To: <20140920110121.GB29419@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 07:01, Thomas Graf wrote:

> Nothing speaks against having such a tc classifier. In fact, having
> the interface consist of only an embedded Netlink attribute structure
> would allow for such a classifier in a very straight forward way.
>
> That doesn't mean everybody should be forced to use the stateful
> tc interface.
>


Agreed. The response was to Jiri's strange statement that now that
he cant use OVS, there is no such api. I point to tc as very capable of
such usage.

> No need for false accusations here. Nobody ever mentioned vendor SDKs.
>

I am sorry to have tied the two together. Maybe not OVS but the approach
described is heaven for vendor SDKs.

> The statement was that the requirement of deriving hardware flows from
> software flows *in the kernel* is not flexible enough for the future
> for reasons such as:
>
> 1) The OVS software data path might be based on eBPF in the future and
>     it is unclear how we could derive hardware flows from that
>     transparently.
>

Who says you cant put BPF in hardware?
And why is OVS defining how BPF should evolve or how it should be used?

> 2) Depending on hardware capabilities. Hardware flows might need to be
>     assisted by software flow counterparts and it is believed that it
>     is the wrong approach to push all the necessary context for the
>     decision down into the kernel. This can be argued about and I don't
>     feel strongly either way.
>

Pointing to the current FDB offload: You can select to bypass
and not use s/ware.

cheers,
jamal
