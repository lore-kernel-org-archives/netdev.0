From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] drivers/net/irda/irda-usb.c: fix buffer overflow
Date: Wed, 14 Jan 2009 20:55:10 -0800 (PST)
Message-ID: <20090114.205510.240650081.davem@davemloft.net>
References: <200901132130.n0DLUsjq014237@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, josevteg@gmail.com, linville@tuxdriver.com,
	samuel@sortiz.org, stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753343AbZAOEzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:55:09 -0500
In-Reply-To: <200901132130.n0DLUsjq014237@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 13 Jan 2009 13:30:54 -0800

> From: Jos-Vicente Gilabert <josevteg@gmail.com>
> 
> Taken from http://bugzilla.kernel.org/show_bug.cgi?id=12397
> 
> We're doing an sprintf of an 11-char string into an 11-char buffer. 
> Whoops.  It breaks firmware uploading.
> 
> Reported-by: Jos-Vicente Gilabert <josevteg@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Patch applied, thanks.
