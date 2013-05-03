From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Fix crash on receiving VLAN frames
Date: Fri, 03 May 2013 16:13:26 -0400 (EDT)
Message-ID: <20130503.161326.2016620759235073104.davem@davemloft.net>
References: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	stephen@networkplumber.org, mlindner@marvell.com
To: kirr@mns.spb.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934274Ab3ECUN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:13:28 -0400
In-Reply-To: <1367590924-8594-1-git-send-email-kirr@mns.spb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kirill Smelkov <kirr@mns.spb.ru>
Date: Fri,  3 May 2013 18:22:04 +0400

> After recent 86a9bad3 (net: vlan: add protocol argument to packet
> tagging functions) my sky2 started to crash on receive of tagged
> frames, with backtrace similar to
 ...
> Fix it.
> 
> P.S.
> 
> Stephen, I wonder, why copy_skb_header() is not used in
> sky2.c::receive_copy() ? Problems, where receive_copy was updated field
> by field showed several times already, e.g.
> 
>     3f42941b    (sky2: propogate rx hash when packet is copied)
>     e072b3fa    (sky2: fix receive length error in mixed non-VLAN/VLAN traffic)
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Mirko Lindner <mlindner@marvell.com>
> Signed-off-by: Kirill Smelkov <kirr@mns.spb.ru>

Applied.
