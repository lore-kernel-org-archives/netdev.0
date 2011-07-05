From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 4/4] packet: Add pre-defragmentation support for ipv4
 fanouts.
Date: Tue, 05 Jul 2011 11:35:41 +0200
Message-ID: <4E12DAED.3070408@inliniac.net>
References: <20110705.020426.1881513648974221645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:33714 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab1GEJgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 05:36:06 -0400
In-Reply-To: <20110705.020426.1881513648974221645.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 11:04 AM, David Miller wrote:
> 
> The skb->rxhash cannot be properly computed if the
> packet is a fragment.  To alleviate this, allow the
> AF_PACKET client to ask for defragmentation to be
> done at demux time.

Does the same limitation exist for IPv6 packets? If I read the patch
correctly the defrag is only done for IPv4.

-- 
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

