From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Was (Re: Route cache performance under stress
Date: Wed, 11 Jun 2003 07:47:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611074007.S39760@shell.cyberus.ca>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <20030610061010.Y36963@shell.cyberus.ca>
 <87el21wzb7.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
   "'Simon Kirby'" <sim@netnation.com>, "'David S. Miller'" <davem@redhat.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <87el21wzb7.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 10 Jun 2003, Florian Weimer wrote:

> In general, the forwarding performance is nowadays specified in pps
> and even flows per second if you look carefully at the data sheets.

Ok, this is interesting. I have never seen the flows per second
used for simple L3 forwading. I have seen them being used for NAT or
firewalling.
Looking at the sprint traffic patterns, i think flows/sec is a
meaningful metric.

> Most vendors have learnt that people want routers with comforting
> worst-case behavior.  However, you have to read carefully, e.g. a
> Catalyst 6500 with Supervisor Engine 1 (instead of 2) can only create
> 650,000 flows per second, even if it has a much, much higher peak IP
> forwarding rate.
>

So 2Mpps of 650Kflows/sec ?

> (The times of routers which died when confronted with a rapid ICMP
> sweep across a /16 are gone for good, I hope.)

We should be able to punish specific misbehaving flows. Do you know
if any routers are implementing proper DOS tracebacks to allow for
inserting drop filters?

cheers,
jamal
