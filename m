From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: mISDN: socket: fix information leak to userland
Date: Sat, 30 Oct 2010 16:49:54 -0700 (PDT)
Message-ID: <20101030.164954.179924837.davem@davemloft.net>
References: <1288429473-21864-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, isdn@linux-pingi.de,
	acme@redhat.com, tj@kernel.org, eparis@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56907
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754282Ab0J3Xtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 19:49:31 -0400
In-Reply-To: <1288429473-21864-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segooon@gmail.com>
Date: Sat, 30 Oct 2010 13:04:33 +0400

> Structure mISDN_devinfo is copied to userland with the field "name"
> that has the last elements unitialized.  It leads to leaking of
> contents of kernel stack memory.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Applied.
