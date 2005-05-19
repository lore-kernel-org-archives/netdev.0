From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] use lookup_create in af_unix
Date: Thu, 19 May 2005 12:27:56 -0700 (PDT)
Message-ID: <20050519.122756.41635751.davem@davemloft.net>
References: <20050512102336.GA26628@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20050512102336.GA26628@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Thu, 12 May 2005 12:23:36 +0200

> currently it opencodes it, but that's in the way of chaning the
> lookup_hash interface.
> 
> I'd prefer to disallow modular af_unix over exporting lookup_create,
> but I'll leave that to you.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

This patch looks fine.  Applied, thanks Chirstophe.

Maybe someone should add to the comments above these fs/namei.c
functions that they will return with the semaphore held even
in error cases.
