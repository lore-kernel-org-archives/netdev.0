From: Robin Holt <holt@sgi.com>
Subject: Re: Zero copy transmit
Date: Tue, 29 Apr 2003 14:33:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030429193336.GA32270@sgi.com>
References: <3EAEC7FF.4040504@sgi.com> <20030429192041.GC17413@Wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Modica <modica@sgi.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030429192041.GC17413@Wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Apr 29, 2003 at 09:20:41PM +0200, Andi Kleen wrote:
> A much better way would be to use the POSIX aio interfaces. They support
> zero copy transmit, but don't require COW. Instead they just tell
> the user process when it is safe to touch the buffer again.
> 
> There was already some code to do aio TCP sending, but it didn't
> do zero copy and was not merged for some reason.
> 
> Also you can already do zero copy transmit using sendfile() 

Users would need to rewrite all their apps to use either the async or
sendfile method.  That assumption seems a little broad.
     
I don't disagree that implementing the remainder of the AIO system
calls would also be good, but is there something wrong with getting
write et. al. to work with zero copy?

Robin Holt
