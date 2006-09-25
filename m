From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 4/6] NetLabel: rework the Netlink attribute handling (part 1)
Date: Mon, 25 Sep 2006 11:12:35 +0200
Message-ID: <20060925091235.GN18349@postel.suug.ch>
References: <20060921165703.251871000@hp.com> <20060921170337.004669000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, sds@epoch.ncsc.mil,
	jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59552 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750815AbWIYJMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 05:12:14 -0400
To: paul.moore@hp.com
Content-Disposition: inline
In-Reply-To: <20060921170337.004669000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* paul.moore@hp.com <paul.moore@hp.com> 2006-09-21 12:57
> -int netlbl_netlink_snd_multicast(struct sk_buff *skb, u32 pid, u32 group)
> +int netlbl_netlink_snd_multicast(struct sk_buff *skb,
> +				 void *buf,
> +				 u32 pid,
> +				 u32 group)
>  {
> +	genlmsg_end(skb, buf);
>  	return genlmsg_multicast(skb, pid, group, GFP_KERNEL);
>  }

This is a bit weird at first, one would expect that the message
is terminated when it is build but I guess this is ok for now.

Rest seems fine.
