From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH 2/2] be2net: workaround to fix a BE bug
Date: Wed, 07 Dec 2011 21:07:20 -0800
Message-ID: <1323320840.1762.61.camel@joe2Laptop>
References: <20111207234424.GA2385@akhaparde-VBox>
	 <20111208.000044.1859009201427703594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ajit.khaparde@Emulex.Com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48776 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750760Ab1LHFHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 00:07:22 -0500
In-Reply-To: <20111208.000044.1859009201427703594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-12-08 at 00:00 -0500, David Miller wrote:
> From: Ajit Khaparde <ajit.khaparde@Emulex.Com>
> > +	if (unlikely(vlan_tx_tag_present(skb) &&
> > +		(skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {
> Poorly formatted, the second line opening first non-space character
> needs to line up precisely after the first column after the if() statements
> opening parenthesis.

In this case I believe you mean after the unlikely(

	if (unlikely(vlan_tx_tag_present(skb) &&
		     (skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {
