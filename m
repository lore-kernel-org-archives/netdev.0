From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Sun, 09 Nov 2014 22:53:07 -0500
Message-ID: <546036A3.3010404@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
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
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:63802 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbaKJDxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:53:12 -0500
Received: by mail-ig0-f181.google.com with SMTP id l13so9138283iga.14
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:53:11 -0800 (PST)
In-Reply-To: <1415530280-9190-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/14 05:51, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add L2 bridge offloading support to rocker driver.  Here, the Linux bridge
> driver is used to collect swdev ports into a tagged (or untagged) VLAN
> bridge.  The swdev will offload from the bridge driver the following L2
> bridging functions:
>
>   - Learning of neighbor MAC addresses on VLAN X  Learned mac/vlan is
> installed in bridge FDB.  (And removed when device unlearns mac/vlan).
> Learning must be turned off on each bridge port to disable the feature in
> the bridge driver.
>

I have quiet a few use cases where the above is a no-no. I dont want
learning of any sort (we have a knob for that in the bridge).
And i dont want learning in hardware to be reflected in software.
Basically this is a policy decision. Introduce a knob to choose whether
hardware learnt addresses should be reflected in software.


Have to run, but will comment when i get the time.

cheers,
jamal
