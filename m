From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 11:48:29 -0700 (PDT)
Message-ID: <20050517.114829.115910656.davem@davemloft.net>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
	<20050517.104947.112621738.davem@davemloft.net>
	<Pine.LNX.4.61.0505171104030.29021@linux.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akepner@sgi.com
In-Reply-To: <Pine.LNX.4.61.0505171104030.29021@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arthur Kepner <akepner@sgi.com>
Date: Tue, 17 May 2005 11:28:05 -0700 (PDT)

> On Tue, 17 May 2005, David S.Miller wrote:
> 
> > Decreasing ipfrag_time is also not an option, because then
> > you break fragmentation for packet radio folks :-)
> 
> Different sysctls for different folks....

Can I tell users to call you when they enable the strict
fragmentation and they can no longer talk UDP to
remote sites outside of their subnet, or it breaks
on their heavily SMP machine due to natural system local
packet reordering?

Packet reordering happens on the local machine with SMP.
There is no way to avoid this.  And when it triggers your
patch will drop frags on the ground all the time.

If you want to fix things, do it without knowingly breaking
stuff that does currently work.
