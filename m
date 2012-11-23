From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] 8139cp: revert "set ring address before
 enabling receiver"
Date: Fri, 23 Nov 2012 14:01:38 -0500 (EST)
Message-ID: <20121123.140138.1311321489349790895.davem@davemloft.net>
References: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dwmw2@infradead.org, jasowang@redhat.com,
	jgarzik@pobox.com, gilboad@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49290 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752715Ab2KWTB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2012 14:01:56 -0500
In-Reply-To: <20121121200729.GA17603@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 21 Nov 2012 21:07:29 +0100

> This patch reverts b01af4579ec41f48e9b9c774e70bd6474ad210db.
> 
> The original patch was tested with emulated hardware. Real
> hardware chokes.
> 
> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=47041
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

I leiu of a response from the realtec folks, I'm applying this
for now.

What I'll do, the next time I merge net into net-next, is revert
this revert and apply Dave's patch.
