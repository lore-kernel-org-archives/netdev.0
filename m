From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: skb_migrate() / net/atm/ipcommon.c
Date: Thu, 25 Sep 2003 09:37:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925163720.GA28244@gaz.sfgoth.com>
References: <20030925121941.GA409@lst.de> <200309251317.h8PDHKkT003298@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200309251317.h8PDHKkT003298@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

chas williams wrote:
> i am fairly sure this function will go away in the future.
> its used to move an existing skb_queue to a new queue, so 
> the queue can be 're-processed'.  it seems to me that it
> might be easier to just find the current tail of the queue
> and process the queue to that point instead of copying to a
> new list.  its on that list of things to do.

Yes, my series of "backend" patches removes ipcommon.[ch] entirely.  I'll
try to send a rediff of them over the weekend if all the currently
pending ATM patches land.

-Mitch
