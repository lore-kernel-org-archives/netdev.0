From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 07:47:53 -0500
Message-ID: <1107175673.7847.130.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311020.08337.hasso@estpak.ee>
	 <1107174338.8021.123.camel@jzny.localdomain>
	 <200501311438.01118.hasso@estpak.ee>
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
In-Reply-To: <200501311438.01118.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 07:38, Hasso Tepper wrote:
> jamal wrote:
> > On Mon, 2005-01-31 at 03:20, Hasso Tepper wrote:
> > > Policing didn't work with IPv6 last time I checked.
> >
> > Really? I take it this is using the u32 classifier?
> > What filter did you use?
> 
> http://mailman.ds9a.nl/pipermail/lartc/2004q2/012422.html
> 
> Got one answer to this in private that "AFAIK it isn't implemented yet".

This?

tc filter add dev eth1.101 parent ffff: protocol all prio 50 handle \
0x101 fw police rate 1024kbit burst 60k drop flowid :101

What are you trying to do? Are you also trying to rate limit ARPs etc
in one shot?

Does this even get hit at all? tc -s would show you stats. I suspect
for one it is not being hit.
Maybe you are trying to use iptables marks that happen
a long time after the ingress has seen the packets (which would 
explain why it is not being hit)? This would be true kernels > 2.6.8 
but not before ..
In other words, it may be a config issue.
If you tell me what it is you are trying to do i could try and set it
up when i come back from work today.

cheers,
jamal
