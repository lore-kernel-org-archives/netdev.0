From: Andi Kleen <ak@suse.de>
Subject: Re: PATCH: bonding might sleep with lock held
Date: Thu, 13 May 2004 21:04:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040513210445.3e08c1f4.ak@suse.de>
References: <20040513082053.GC27682@wotan.suse.de>
	<200405131844.i4DIijD3018359@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200405131844.i4DIijD3018359@death.nxdomain.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 May 2004 11:44:45 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 	It will race against the timers, although I don't see anything
> in there offhand that would conflict.  It just feels somehow unclean to
> do it without the lock.

Why should the timers care if there can be a packet received from the 
network or not?  (this is all what dev_remove_pack prevents) 

-Andi
