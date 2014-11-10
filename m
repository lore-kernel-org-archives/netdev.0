From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 09:18:26 +0100
Message-ID: <20141110081826.GE1850@nanopsycho.orion>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
 <1415530280-9190-11-git-send-email-jiri@resnulli.us>
 <546036A3.3010404@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:51938 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930AbaKJIS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 03:18:28 -0500
Received: by mail-wi0-f179.google.com with SMTP id h11so9473614wiw.6
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 00:18:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <546036A3.3010404@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 10, 2014 at 04:53:07AM CET, jhs@mojatatu.com wrote:
>On 11/09/14 05:51, Jiri Pirko wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>Add L2 bridge offloading support to rocker driver.  Here, the Linux bridge
>>driver is used to collect swdev ports into a tagged (or untagged) VLAN
>>bridge.  The swdev will offload from the bridge driver the following L2
>>bridging functions:
>>
>>  - Learning of neighbor MAC addresses on VLAN X  Learned mac/vlan is
>>installed in bridge FDB.  (And removed when device unlearns mac/vlan).
>>Learning must be turned off on each bridge port to disable the feature in
>>the bridge driver.
>>
>
>I have quiet a few use cases where the above is a no-no. I dont want
>learning of any sort (we have a knob for that in the bridge).

I would love to see your code. Please do share.

>And i dont want learning in hardware to be reflected in software.
>Basically this is a policy decision. Introduce a knob to choose whether
>hardware learnt addresses should be reflected in software.

This can be easily done as a bridge option I believe. If you are ok with
that, I will add a patch (either in re-post or as a follow-up)

>
>
>Have to run, but will comment when i get the time.
>
>cheers,
>jamal
>
