From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 14:57:38 -0400
Message-ID: <200505171457.38719.jheffner@psc.edu>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site> <20050517.104947.112621738.davem@davemloft.net> <m1zmut7l5q.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1zmut7l5q.fsf@muc.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 17 May 2005 02:38 pm, Andi Kleen wrote:
> "David S. Miller" <davem@davemloft.net> writes:
> > From: Arthur Kepner <akepner@sgi.com>
> > Date: Tue, 17 May 2005 09:18:26 -0700 (PDT)
> >
> >>   1) Fragments must arrive in order (or in reverse order) -
> >>      out of order fragments are dropped.
> >
> > Even the most simplistic flow over the real internet
> > can get slight packet reordering.
> >
> > Heck, reordering happens on SMP on any network.
> >
> > IP is supposed to be resilient to side effects of network
> > topology, and one such common side effect is packet reordering.
> > It's common, it's fine, and the networking stack deals with it
> > gracefully.  Strict reassembly does not.
>
> If anything it would be better as a per route flag.
> Then you could set it only for your local network
> where you know Gigabit happens and reordering might
> be avoidable in some cases.

It would be better still to have a per-route packet reassembly timeout in 
milliseconds.  Expecting perfect ordering seems very fragile even for a LAN.

  -John
