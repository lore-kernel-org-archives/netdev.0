From: David Miller <davem@davemloft.net>
Subject: Re: [patch 10/11] hysdn: remove the packed attribute from
 PofTimStamp_tag
Date: Wed, 30 Jul 2008 16:48:27 -0700 (PDT)
Message-ID: <20080730.164827.237657466.davem@davemloft.net>
References: <200807301937.m6UJbhxo012458@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com, kkeil@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754872AbYG3Xs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:48:27 -0400
In-Reply-To: <200807301937.m6UJbhxo012458@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:42 -0700

> Remove the packed attribute from PofTimStamp_tag in the hysdn driver as the
> thing being packed is just an array of chars and so is unpackable.
> 
> This deals with a compiler warning:
> 
> In file included from drivers/isdn/hysdn/hysdn_boot.c:19:
> drivers/isdn/hysdn/hysdn_pof.h:63: warning: 'packed' attribute ignored for field of type 'unsigned char[40]'
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
