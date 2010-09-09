From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/core: add lock context change annotations in
 net/core/sock.c
Date: Thu, 09 Sep 2010 15:03:04 -0700 (PDT)
Message-ID: <20100909.150304.246518344.davem@davemloft.net>
References: <1283953728-15302-1-git-send-email-namhyung@gmail.com>
	<1283953728-15302-2-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: namhyung@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283953728-15302-2-git-send-email-namhyung@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Namhyung Kim <namhyung@gmail.com>
Date: Wed,  8 Sep 2010 22:48:48 +0900

> __lock_sock() and __release_sock() releases and regrabs lock but
> were missing proper annotations. Add it. This removes following
> warning from sparse. (Currently __lock_sock() does not emit any
> warning about it but I think it is better to add also.)
> 
>  net/core/sock.c:1580:17: warning: context imbalance in '__release_sock' - unexpected unlock
> 
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Applied.
