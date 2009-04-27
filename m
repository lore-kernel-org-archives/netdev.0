From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] OF device tree handling of PHY drivers
Date: Mon, 27 Apr 2009 02:54:36 -0700 (PDT)
Message-ID: <20090427.025436.68188155.davem@davemloft.net>
References: <20090425224458.32392.31296.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, afleming@freescale.com, netdev@vger.kernel.org
To: grant.likely@secretlab.ca
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20090425224458.32392.31296.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@secretlab.ca>
Date: Sat, 25 Apr 2009 16:52:34 -0600

> This series adds common code for reading PHY connection data out of
> the OpenFirmware device tree.  This simplifies the network drivers
> which use the device tree and which currently implement their own
> solutions for reading the PHY data out of the device tree directly.
> 
> I would like to see this series, or at least the core changes (1-4)
> plus the tested drivers (5-8 & 12, but #12 is a new driver and it
> may need more review), go into -next for 2.6.31.
> 
> Due to dependencies, I think it is easiest if all of them go in via the
> same tree.  David, are you willing to merge them via yours?  Four of the
> patches are outside of drivers/net (patches 1 and 4 touch drivers/of/,
> and patches 9 & 10 touch arch/powerpc), but I personally have no issues
> if those changes go through you.  I just need to double check with BenH.

I've applied all of these patches to net-next-2.6, thanks.

>   git://git.secretlab.ca/git/linux-2.6 next-net

You know, if you had actually based this tree on net-next-2.6
I could have pulled from it.  I actually tried, and I got a
lot of upstream stuff I wasn't ready to get in that tree just
yet :-/
