From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [PATCH -next] 3c515: fix using pnp_get_resource when CONFIG_ISAPNP=n
Date: Fri, 16 May 2008 12:58:03 -0600
Message-ID: <200805161258.04265.bjorn.helgaas@hp.com>
References: <20080516103524.0b00ffb6.randy.dunlap@oracle.com> <200805161215.06046.bjorn.helgaas@hp.com> <482DD0AF.7070003@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>,
	linux-next@vger.kernel.org, akpm <akpm@linux-foundation.org>,
	Adam M Belay <abelay@mit.edu>, Adam Belay <ambx1@neo.rr.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <482DD0AF.7070003@oracle.com>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 May 2008 12:21:35 pm Randy Dunlap wrote:
> Bjorn Helgaas wrote:
> > I prefer CONFIG_PNP to __ISAPNP__ in general, but I see
> > you're just following the other tests in the same file.
> 
> Yes.  And it would need to be CONFIG_ISAPNP, not CONFIG_PNP.

Huh.  Sure enough.  I hadn't even noticed pnp_find_dev().
I'm not sure why pnp_find_dev() should be under CONFIG_ISAPNP
rather than CONFIG_PNP, other than the fact that it uses
ISAPNP_ANY_ID.

On the other hand, there are only 25-30 users of pnp_find_dev();
maybe I should just look at converting them and nuking the
compat interfaces completely.

Bjorn
