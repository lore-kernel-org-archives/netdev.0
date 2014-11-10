From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 07:56:15 -0500
Message-ID: <5460B5EF.80103@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>	<1415530280-9190-2-git-send-email-jiri@resnulli.us>	<54603270.509@mojatatu.com> <20141110.002336.70350092543746386.davem@davemloft.net> <5460AA45.6000007@mojatatu.com> <5460B090.7080106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:58349 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbaKJM4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 07:56:20 -0500
Received: by mail-ig0-f171.google.com with SMTP id hl2so16333610igb.10
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 04:56:19 -0800 (PST)
In-Reply-To: <5460B090.7080106@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14 07:33, Daniel Borkmann wrote:

> $ git grep -n MAX_PHYS_PORT_ID_LEN
> include/linux/netdevice.h:756:#define MAX_PHYS_PORT_ID_LEN 32
> include/linux/netdevice.h:762:  unsigned char id[MAX_PHYS_PORT_ID_LEN];
> net/core/rtnetlink.c:871:              +
> nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
> net/core/rtnetlink.c:1199:      [IFLA_PHYS_PORT_ID]     = { .type =
> NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
>
> ... and based on commit 66cae9ed6bc4 ("rtnl: export physical port id
> via RT netlink") only exported as read-only.
>

I guess it is *not exported* if no user space code sees it.
If that is the case, I agree that my suggestion is unneeded.

cheers,
jamal
