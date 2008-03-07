From: Nathaniel Case <ncase@xes-inc.com>
Subject: Re: [Pasemi-linux] I2C MDIO support for pasemi_mac driver
Date: Fri, 07 Mar 2008 13:28:11 -0600
Message-ID: <1204918091.8864.36.camel@localhost.localdomain>
References: <1204911643.8864.15.camel@localhost.localdomain>
	 <20080307183738.GA22366@lixom.net>  <20080307184854.GA23402@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pasemi-linux@ozlabs.org,
	afleming@freescale.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:52961 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839AbYCGUIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 15:08:16 -0500
In-Reply-To: <20080307184854.GA23402@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-03-07 at 12:48 -0600, Olof Johansson wrote:
> On second thought, it might be a better idea to change from BUS:ID to
> BUSTYPE:BUS:ID in phylib, to separate the namespaces.
> 
> That, plus a way to get to an i2c bus number from a device tree node,
> and we should be all set. That might be tricker though.

I like this idea, since it would eliminate the need for the MAC driver
to decide policy on a "global" MDIO bus numbering scheme.  I was also
trying to make it compatible with the case (however unlikely) of having
both an SMBus PHY and a bit-banged MDIO PHY.

For getting the I2C bus number from a device tree node, I've just been
parsing the node->full_name for the number following the i2c@XXXXXX with
an ugly string parsing function (xes_of_get_node_loc() in one of the
older patches I sent you).

- Nate Case <ncase@xes-inc.com>

