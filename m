From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [RFC] netlink broadcast return value
Date: Mon, 2 Feb 2009 14:35:09 -0800
Message-ID: <200902021435.09941.inaky@linux.intel.com>
References: <4985A4C5.4050908@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4985A4C5.4050908@netfilter.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 February 2009, Pablo Neira Ayuso wrote:

> == genlmsg_multicast (calls nlmsg_multicast) ==
> net/netlink/genetlink.c			: ignores return value
> drivers/acpi/event.c			: printk error
> fs/dquot.c				: printk error (if err != -ESRCH)
> net/wireless/nl80211.c			: ignores return value
>
> In short, I think that the change that I'm proposing would also require
> to fix some netlink_broadcast() clients to skip ENOBUFS errors: they are
> not meaningful for them since they assume that Netlink is unreliable and
> so the return value does not provide any useful information.

You are missing a few callers in net/wimax. Which kernel version did you
do the analysis on?

-- 
Inaky
