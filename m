From: "Rask Ingemann Lambertsen" <rask@sygehus.dk>
Subject: Re: A better way to get driver stats than parsing /proc/net/dev ?
Date: Wed, 21 May 2003 18:39:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521173554.M92611@sygehus.dk>
References: <3E967535.2000409@candelatech.com> <slrnb9dn9r.fef.lunz@stoli.localnet> <3E96FAE1.7030302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3E96FAE1.7030302@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Apr 2003 10:26:57 -0700, Ben Greear wrote
> Jason Lunz wrote:
> > greearb@candelatech.com said:
> > 
> >>Is there an ioctl or some other binary means of getting the info that
> >>/proc/net/dev provides?
> > 
> > You can do it with netlink sockets. See print_linkinfo() in the iproute2
> > code.
> 
> Seems that a lot of code is needed just to read the stats :(

Maybe it is easier to parse the output from "ip -s -s link show [iface]". At 
least you get all the counters, which you don't from /proc/net/dev.

-- 
Regards,
Rask Ingemann Lambertsen
