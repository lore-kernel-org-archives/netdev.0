From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: remove redundant NULL pointer checks prior to
 kfree in drivers/net/slip.c
Date: Sun, 24 Apr 2005 18:59:54 -0700
Message-ID: <20050424185954.7c33ce58.davem@davemloft.net>
References: <Pine.LNX.4.62.0504112311130.2480@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, loz@holmes.demon.co.uk,
	waltje@uwalt.nl.mugnet.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262433AbVDYCIC@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.62.0504112311130.2480@dragon.hyggekrogen.localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Apr 2005 23:15:40 +0200 (CEST)
Jesper Juhl <juhl-lkml@dif.dk> wrote:

> kfree() checks for NULL. Checking prior to calling it is redundant.
> This patch removes these redundant checks from drivers/net/slip.c
> 
> Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

Applied, thanks Jesper.
