From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: How do I track TG3 peculiarities?
Date: Sun, 7 Sep 2003 22:09:26 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030907220926.G18482@schatzie.adilger.int>
References: <m31xuss0ht.fsf@maxwell.lnxi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederman@lnxi.com>
Content-Disposition: inline
In-Reply-To: <m31xuss0ht.fsf@maxwell.lnxi.com>; from ebiederman@lnxi.com on Sun, Sep 07, 2003 at 04:21:50PM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sep 07, 2003  16:21 -0600, Eric W. Biederman wrote:
> Below is one good oops we have captured.  I would have to check but
> I believe we have updated the tg3 driver in this instance to the
> one that comes with 2.4.23-pre3.
> 
> The very puzzling part is that in the crashes I don't see the tg3
> driver at all just the network stack.  All module addresses according
> to /proc/ksyms started with at 0xf8, and the tg3 driver was built as
> a module.
> 
> I have been having trouble understanding why skb_clone would be called
> to transmit a packet.  Any ideas?

Do you have the stack overflow checking enabled?  That has been a source
of problems for us.  It was especially difficult to reproduce, because it
only happened during a double interrupt.

Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://www-mddsp.enel.ucalgary.ca/People/adilger/
