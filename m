From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Compiler warning and NULL pointer
 dereference fix
Date: Thu, 11 Dec 2008 21:32:00 -0800 (PST)
Message-ID: <20081211.213200.180924446.davem@davemloft.net>
References: <20081211184312.30832.25526.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	geert.uytterhoeven@sonycom.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37848
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757570AbYLLFb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:31:59 -0500
In-Reply-To: <20081211184312.30832.25526.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Thu, 11 Dec 2008 13:43:12 -0500

> Fix the two compiler warnings show below.  Thanks to Geert Uytterhoeven for
> finding and reporting the problem.
> 
>  net/netlabel/netlabel_unlabeled.c:567: warning: 'entry' may be used
>    uninitialized in this function
>  net/netlabel/netlabel_unlabeled.c:629: warning: 'entry' may be used
>    uninitialized in this function
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, thanks Paul.
