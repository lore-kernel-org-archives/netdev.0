From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [RFC] Wireless extensions rethink
Date: Thu, 17 Jun 2004 11:56:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617185605.GA32216@bougret.hpl.hp.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0103AF626C@orsmsx402.amr.corp.intel.com> <40CF263E.70009@home.nl> <1087377197.25912.54.camel@sfeldma-mobl2.dsl-verizon.net> <40D08769.3070106@home.nl> <20040616204248.GA23617@bougret.hpl.hp.com> <40D0BD5B.201@pobox.com> <20040616223316.GA29618@bougret.hpl.hp.com> <40D0D265.3070804@pobox.com> <20040617174717.GA30460@bougret.hpl.hp.com> <40D1E185.2010201@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gertjan van Wingerde <gwingerde@home.nl>, sfeldma@pobox.com,
        netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D1E185.2010201@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 02:23:01PM -0400, Jeff Garzik wrote:
> Jean Tourrilhes wrote:
> >
> >	As a matter of fact, I tried the strongly type approach you
> >advocate and find its kernel overhead not acceptable. Note that people
> >not using wireless have to suffer from this bloat, and wireless
> >extensions are used in embeeded platforms such as OpenAP, iPaq and
> >Zaurus where footprint matters.
> 
> As you can see from the patch and header I have attached, there is 
> _zero_ change to storage.  No additional bloat.

	I've never talked of driver bloat, which I don't really care
about. I'm talking of *kernel* bloat. And not about storage bloat, but
code bloat.
	When I designed the API, I did verify this carefully :
	http://marc.theaimsgroup.com/?l=linux-kernel&m=100829443600986&w=2

> Sorry, keeping compatibility with drivers outside the kernel is _not_ a 
> priority here.  Backward compatibility is how this cruft accumulated in 
> the first place.
> 
> Go ahead and assume that drivers outside the kernel will break.  This is 
> no different from vendor drivers -- if the driver is not in the kernel, 
> it doesn't exist.

	Jeff, this is not the way I work. For example, there are good
reasons why the Atheros driver is outside the kernel.

> 	Jeff

	Jean
