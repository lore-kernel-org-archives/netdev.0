From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 6 Aug 2014 16:47:11 +0100
Message-ID: <20140806154711.GQ30282@n2100.arm.linux.org.uk>
References: <53E24147.4050304@parkeon.com> <53E24525.2020809@mentor.com> <53E24A99.2020604@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Lynch <Nathan_Lynch@mentor.com>,
	Martin Fuzzey <mfuzzey@parkeon.com>, netdev@vger.kernel.org,
	festevam@gmail.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Stefano Babic <sbabic@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:39198 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751857AbaHFPrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:47:23 -0400
Content-Disposition: inline
In-Reply-To: <53E24A99.2020604@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2014 at 05:32:41PM +0200, Stefano Babic wrote:
> Hi Nathan, Martin,
> 
> On 06/08/2014 17:09, Nathan Lynch wrote:
> > On 08/06/2014 09:52 AM, Martin Fuzzey wrote:
> >> Hi all,
> >>
> >> I am using the fec ethernet driver on a i.MX53 SoC.
> >>
> >> All was working fine on 3.13 but, after upgrading to 3.16 I now get a
> >> panic on suspend:
> > 
> > Same issue reported here:
> > 
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2014-August/277728.html
> > 
> > a71e3c37960c (net: phy: Set the driver when registering an MDIO bus
> > device) has been implicated; try reverting that.
> > 
> 
> I confirm this issue (on a i.MX35). The ndev pointer is NULL in the
> suspend function. I added the check for the pointer:

As Nathan says, the problem is caused by a71e3c37960c and the fix which
will soon be merged into mainline and stable trees will be a revert of
that commit.

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
