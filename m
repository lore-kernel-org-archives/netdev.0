From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch iproute2 6/6] bridge/link: add learning_sync policy flag
Date: Thu, 04 Dec 2014 08:26:45 -0500
Message-ID: <54806115.9080008@mojatatu.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <1417683438-10935-7-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org, hemal@broadcom.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:33199 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaLDN0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 08:26:50 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so18696658igd.2
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 05:26:49 -0800 (PST)
In-Reply-To: <1417683438-10935-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/14 03:57, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add 'learned_sync' flag to turn on/off syncing of learned FDB entries from
> offload device to bridge's FDB.   Flag would be set/cleared in on SELF using
> hwmode qualifier 'swdev'.  E.g.:
>
>    $ sudo bridge link set dev swp1 hwmode swdev learning_sync on
>
>    $ bridge -d link show dev swp1
>    2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 2
>        hairpin off guard off root_block off fastleave off learning off flood off
>    2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
>        learning on learning_sync on hwmode swdev
>
> Adds new IFLA_BRPORT_LEARNING_SYNC attribute for IFLA_PROTINFO on the SELF
> brport.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I actually dont think any of these patches needed an ack because they
are off. My ack is just to show support (despite the noun challenges).

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
