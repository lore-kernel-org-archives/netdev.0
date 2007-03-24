From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/5 2.6.21-rc4] l2tp: pppol2tp changes to existing kernel
 headers
Date: Sat, 24 Mar 2007 15:00:55 +0100
Message-ID: <46052F17.9000802@trash.net>
References: <200703232307.l2NN7ROx010811@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbXCXOBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 10:01:00 -0400
In-Reply-To: <200703232307.l2NN7ROx010811@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
> +/* For PPPIOCGL2TPSTATS */
> +struct pppol2tp_ioc_stats {
> +	__u16	tunnel_id;	/* redundant */
> +	__u16	session_id;	/* if zero, get tunnel stats */

This leaves a 32 bit hole. Maybe move using_ipsec up.

> +	__u64	tx_packets;
> +	__u64	tx_bytes;
> +	__u64	tx_errors;
> +	__u64	rx_packets;
> +	__u64	rx_bytes;
> +	__u64	rx_seq_discards;
> +	__u64	rx_oos_packets;
> +	__u64	rx_errors;
> +	int	using_ipsec;	/* valid only for session_id == 0 */
> +};

