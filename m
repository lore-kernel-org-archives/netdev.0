From: Aron Griffis <aron@hp.com>
Subject: Re: ifconfig bug removes aliases
Date: Sat, 13 Mar 2004 10:28:30 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313152830.GC7080@time.flatmonk.org>
References: <20040310212056.GA5661@time.flatmonk.org> <Pine.LNX.4.58.0403131204500.1130@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403131204500.1130@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:	[Sat Mar 13 2004, 05:07:05AM EST]
> On Wed, 10 Mar 2004, Aron Griffis wrote:
> 
> > Hello, here is the sequence:
> >
> >     ifconfig eth0:1 10.10.10.1 netmask 255.255.0.0
> >     ifconfig eth0:2 10.10.10.2 netmask 255.255.0.0
> >     ifconfig eth0:1 down
> >
> > At this point eth0:2 has disappeared also.  It appears that the aliases
> > must be on the same subnet for this to occur, and the creation order is
> > also important.
> 
> 	From inet_del_ifa:
> 
> /* 1. Deleting primary ifaddr forces deletion all secondaries */

Thanks, I am aware of that behavior, but that is not the bug I am
describing.  In this case it is the deletion of one alias that causes
another to be removed as well.

Aron
