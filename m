From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Remove unnecessary check in net/sunrpc/svcsock.c
Date: Thu, 28 Sep 2006 14:37:24 -0700 (PDT)
Message-ID: <20060928.143724.77240146.davem@davemloft.net>
References: <1159371290.9125.6.camel@alice>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46775
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932124AbWI1VhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:37:21 -0400
To: snakebyte@gmx.de
In-Reply-To: <1159371290.9125.6.camel@alice>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Sesterhenn <snakebyte@gmx.de>
Date: Wed, 27 Sep 2006 17:34:49 +0200

> coverity spotted this one as possible dereference in the dprintk(),
> but since there is only one caller of svc_create_socket(), which always
> passes a valid sin, we dont need this check.
> 
> Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

Applied, thanks Eric.
