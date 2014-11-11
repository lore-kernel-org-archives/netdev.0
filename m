From: "M. Braun" <michael-dev@fami-braun.de>
Subject: Re: [patch net-next v2 02/10] net: introduce generic switch
 devices support
Date: Tue, 11 Nov 2014 10:49:36 +0100
Message-ID: <5461DBB0.5090107@fami-braun.de>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p04-ob.smtp.rzone.de ([81.169.146.178]:58264 "EHLO
	mo4-p04-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaKKJ5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 04:57:55 -0500
In-Reply-To: <1415530280-9190-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 09.11.2014 um 11:51 schrieb Jiri Pirko:
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> +	ndo_sw_parent_get_id - ...

here the ndo is called get_id

but

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> + *
> + * int (*ndo_sw_parent_id_get)(struct net_device *dev,
> + *			       struct netdev_phys_item_id *psid);
> @@ -1168,6 +1174,10 @@ struct net_device_ops {
> +	int			(*ndo_sw_parent_id_get)(struct net_device *dev,
> +							struct netdev_phys_item_id *psid);

here it is call id_get, which is similar but not the same.

Regards,
 M. Braun
