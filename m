From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Network oops
Date: Wed, 12 Jun 2002 10:42:40 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae81bp$q41$2@main.gmane.org>
References: <OF8ADD9FF7.49EC72C0-ON85256BD6.005CEBAC@raleigh.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Donald Becker <becker@scyld.com>, <linux-net@vger.kernel.org>,
   <linux-net-owner@vger.kernel.org>, <netdev@oss.sgi.com>,
   <pekkas@netcore.fi>
Return-path: <owner-netdev@oss.sgi.com>
To: Mala Anand <manand@us.ibm.com>
In-Reply-To: <OF8ADD9FF7.49EC72C0-ON85256BD6.005CEBAC@raleigh.ibm.com>
List-Id: netdev.vger.kernel.org

On Wed, 12 Jun 2002, Mala Anand wrote:

> >> On Mon, 10 Jun 2002, Mala Anand wrote:
> 
> >>  I have seen this problem with this NIC.  You need to increase
> >> the number of buffers in the RX and TX ring in eepro100.c file.
> >> Right now it is set to 32, change it to 256 or 128 this error
> >> will go away.
> 
> > Donald Becker wrote:
> >Changing the Tx queue size or number of Rx skbuffs waiting to be filled
> >will not fix a problem.  It might mask some problem e.g. a temporary
> >shortage of skbuffs, but it doesn't fix anything.
> 
> The problem what I saw was resource problem and as a result I had packet
> drops.  The
> input rate was high and the driver didn't have enough resources to handle.
> It was a pure resource problem.
> --

I think the problem Donald Becker is referring to is the
fact that it oopses when out of resources, (or whatever),
and that is not a graceful and acceptable thing. Adding
resources pushes the problem to a point under additional
stress/load/consumption. It would be nice if that were
handled gracefully.

thanks,
Nivedita
