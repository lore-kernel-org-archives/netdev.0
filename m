From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 09:25:51 -0500
Message-ID: <1107181551.7847.193.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311502.56796.hasso@estpak.ee>
	 <1107178770.7840.151.camel@jzny.localdomain>
	 <200501311614.31397.hasso@estpak.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200501311614.31397.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 09:14, Hasso Tepper wrote:
> jamal wrote:
> > On Mon, 2005-01-31 at 08:02, Hasso Tepper wrote:
> > > All traffic coming from eth1.101 interface.
> >
> > eth1.101 is an alias? You may have issues there. Maybe not if the
> > attach to that interface worked.
> 
> No, vlan.

That should be fine then

> > Theres other ways to do it[1] but if theres a bug in this it needs
> > fixing.

[..]
> > And then later just referenced it without having to repeat the rate
> > like so:
> > filter add dev eth0 parent ffff: protocol ip prio 6 u32 match ip src \
> > 10.0.0.21/32 flowid 1:16 \
> > action police index 1
> 
> Hmmm ... I even didn't know about index. Yes, something like that would do 
> as well probably. I'll do some tests later today with this. Actions don't 
> help me though as I'm using 2.4 kernel for production.

Theres an extra "index 1" in all those examples. remove the first one (I
am sure you will find out when experimenting what the correct syntax
is).
Unfortunately this "index" thing continues to be a big secret although i
have pointed it a few times. Bart should probably add it to his HOWTO.

All actions also have indices and are therefore shareable. 

cheers,
jamal
