From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 06/12 -Rev2] rtnetlink changes.
Date: Sun, 22 Jul 2007 19:10:37 +0200
Message-ID: <46A38F8D.6080109@trash.net>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com> <20070722090553.7787.28728.sendpatchset@K50wks273871wss.in.ibm.com>
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
Received: from stinky.trash.net ([213.144.137.162]:44112 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbXGVRMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 13:12:48 -0400
In-Reply-To: <20070722090553.7787.28728.sendpatchset@K50wks273871wss.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> diff -ruNp org/include/linux/if_link.h rev2/include/linux/if_link.h
> --- org/include/linux/if_link.h	2007-07-20 16:33:35.000000000 +0530
> +++ rev2/include/linux/if_link.h	2007-07-20 16:35:08.000000000 +0530
> @@ -78,6 +78,8 @@ enum
>  	IFLA_LINKMODE,
>  	IFLA_LINKINFO,
>  #define IFLA_LINKINFO IFLA_LINKINFO
> +	IFLA_TXBTHSKB,		/* Driver support for Batch'd skbs */
> +#define IFLA_TXBTHSKB IFLA_TXBTHSKB


Ughh what a name :) I prefer pronouncable names since they are
much easier to remember and don't need comments explaining
what they mean.

But I actually think offering just an ethtool interface would
be better, at least for now.

