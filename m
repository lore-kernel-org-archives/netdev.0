From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: skb_migrate() / net/atm/ipcommon.c
Date: Thu, 25 Sep 2003 09:17:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251317.h8PDHKkT003298@ginger.cmf.nrl.navy.mil>
References: <hch@lst.de>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: Message from Christoph Hellwig <hch@lst.de>
   of "Thu, 25 Sep 2003 14:19:41 +0200." <20030925121941.GA409@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>net/atm/ipcommon.c has a single function in it, skb_migrate which
>looks pretty generic and his this comment ontop of it:
>
> *
> * This function should live in skbuff.c or skbuff.h.
> *
>
>So does this comment make sense, should it go into common code
>(and kill the major ugliness in net/atm/Makefile :))

i am fairly sure this function will go away in the future.
its used to move an existing skb_queue to a new queue, so 
the queue can be 're-processed'.  it seems to me that it
might be easier to just find the current tail of the queue
and process the queue to that point instead of copying to a
new list.  its on that list of things to do.
