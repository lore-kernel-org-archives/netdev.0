From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/14] drivers/net/typhoon.c: delete double assignment
Date: Wed, 27 Oct 2010 12:24:21 -0700 (PDT)
Message-ID: <20101027.122421.27814587.davem@davemloft.net>
References: <1288088743-3725-1-git-send-email-julia@diku.dk>
	<1288088743-3725-8-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: julia@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755504Ab0J0TX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:23:57 -0400
In-Reply-To: <1288088743-3725-8-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>
Date: Tue, 26 Oct 2010 12:25:36 +0200

> From: Julia Lawall <julia@diku.dk>
> 
> Delete successive assignments to the same location.  The current definition
> does not initialize the respRing structure, which has the same type as the
> cmdRing structure, so initialize that one instead.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
...
> Signed-off-by: Julia Lawall <julia@diku.dk>

Applied.
