From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2][RFC] vlan: use pskb_copy() when inserting a vlan
 tag by hand
Date: Mon, 07 Jul 2008 23:01:18 +0200
Message-ID: <4872841E.1030609@trash.net>
References: <20080707205646.GB12997@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@cam.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38404 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122AbYGGVBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:01:22 -0400
In-Reply-To: <20080707205646.GB12997@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> When inserting a vlan tag into an skb by hand (in the case the
> target network device hardware does not support inserting a vlan
> tag by passing it in via the TX descriptor), making a copy of the
> skb to be modified by calling skb_copy() is overkill, since
> skb_copy() will needlessly linearize the skb, copying of all of
> the fragmented data around, and checksumming the paket in software
> even if the hardware is perfectly capable of doing that by itself.
> 
> For this case, pskb_copy() does exactly what is needed and no more,
> so use that instead.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

This looks fine to me.
