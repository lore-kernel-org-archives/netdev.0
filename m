From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] use lookup_create in af_unix
Date: Thu, 19 May 2005 21:30:06 +0200
Message-ID: <20050519193006.GA28725@lst.de>
References: <20050512102336.GA26628@lst.de> <20050519.122756.41635751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050519.122756.41635751.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 12:27:56PM -0700, David S. Miller wrote:
> Maybe someone should add to the comments above these fs/namei.c
> functions that they will return with the semaphore held even
> in error cases.

I sent a patch to Andrew that adds this comment and various others that
were in af_unix.c to lookup_create.
