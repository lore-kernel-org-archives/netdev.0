From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 15:02:56 +0200
Message-ID: <200501311502.56796.hasso@estpak.ee>
References: <1107123123.8021.80.camel@jzny.localdomain> <200501311438.01118.hasso@estpak.ee> <1107175673.7847.130.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1107175673.7847.130.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-01-31 at 07:38, Hasso Tepper wrote:
> > jamal wrote:
> > > On Mon, 2005-01-31 at 03:20, Hasso Tepper wrote:
> > > > Policing didn't work with IPv6 last time I checked.
> > >
> > > Really? I take it this is using the u32 classifier?
> > > What filter did you use?
> >
> > http://mailman.ds9a.nl/pipermail/lartc/2004q2/012422.html
> >
> > Got one answer to this in private that "AFAIK it isn't implemented
> > yet".
>
> This?
>
> tc filter add dev eth1.101 parent ffff: protocol all prio 50 handle \
> 0x101 fw police rate 1024kbit burst 60k drop flowid :101
>
> What are you trying to do? Are you also trying to rate limit ARPs etc
> in one shot?

All traffic coming from eth1.101 interface.

> Does this even get hit at all? tc -s would show you stats. I suspect
> for one it is not being hit.

As far as I remember situation was exactly as I described. This worked for 
IPv4 traffic, but not for IPv6 traffic.

> Maybe you are trying to use iptables marks that happen
> a long time after the ingress has seen the packets (which would
> explain why it is not being hit)? This would be true kernels > 2.6.8
> but not before ..

This test was done with 2.6.6.

> In other words, it may be a config issue.

Would be nice ;).

> If you tell me what it is you are trying to do i could try and set it
> up when i come back from work today.

I'd like to limit _all_ traffic coming in from one particular interface to 
the one common limit. No matter what traffic it is - IPv4 or IPv6. Sum of 
traffic should be the one I specify.


-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
