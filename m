From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH nf-next,v2] gtp: add initial driver for datapath of
 GPRS Tunneling Protocol (GTP-U)
Date: Tue, 10 May 2016 12:27:35 -0400 (EDT)
Message-ID: <20160510.122735.2275935466949423395.davem@davemloft.net>
References: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, laforge@gnumonks.org, aschultz@tpip.net,
	openbsc@lists.osmocom.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782AbcEJQ1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 12:27:38 -0400
In-Reply-To: <1462748148-17764-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon,  9 May 2016 00:55:48 +0200

> This is an initial implementation of a netdev driver for GTP datapath
> (GTP-U) v0 and v1, according to the GSM TS 09.60 and 3GPP TS 29.060
> standards. This tunneling protocol is used to prevent subscribers from
> accessing mobile carrier core network infrastructure.
> 
> This implementation requires a GGSN userspace daemon that implements the
> signaling protocol (GTP-C), such as OpenGGSN [1]. This userspace daemon
> updates the PDP context database that represents active subscriber
> sessions through a genetlink interface.
> 
> For more context on this tunneling protocol, you can check the slides
> that were presented during the NetDev 1.1 [2].
> 
> Only IPv4 is supported at this time.
> 
> [1] http://git.osmocom.org/openggsn/
> [2] http://www.netdevconf.org/1.1/proceedings/slides/schultz-welte-osmocom-gtp.pdf
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> v2: Rebase on top of current HEAD to resolve minor conflict with recent PPP
>     updates in include/uapi/linux/if_link.h so this applies cleanly.

Applied, thanks.
