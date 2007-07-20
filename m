From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 02/10] Networking include file changes.
Date: Fri, 20 Jul 2007 11:59:35 +0200
Message-ID: <46A08787.8040501@trash.net>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain> <20070720063216.26341.80316.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rdreier@cisco.com, johnpol@2ka.mipt.ru,
	Robert.Olsson@data.slu.se, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, xma@us.ibm.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56661 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757987AbXGTKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 06:00:52 -0400
In-Reply-To: <20070720063216.26341.80316.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> diff -ruNp org/include/linux/netdevice.h new/include/linux/netdevice.h
> --- org/include/linux/netdevice.h	2007-07-20 07:49:28.000000000 +0530
> +++ new/include/linux/netdevice.h	2007-07-20 08:30:55.000000000 +0530
> @@ -264,6 +264,8 @@ enum netdev_state_t
>  	__LINK_STATE_QDISC_RUNNING,
>  };
>  
> +/* Minimum length of device hardware queue for batching to work */
> +#define MIN_QUEUE_LEN_BATCH	16


Is there any downside in using batching with smaller queue sizes?
