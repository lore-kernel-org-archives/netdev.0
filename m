From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v2a 1/2] dt: Document a compatible entry for MDIO
 ethernet Phys
Date: Thu, 20 Mar 2014 10:19:24 -0600
Message-ID: <20140320161924.GA8855@obsidianresearch.com>
References: <1395267324-5788-1-git-send-email-jgunthorpe@obsidianresearch.com>
 <532AA634.5090707@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <532AA634.5090707@codethink.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2014 at 09:26:28AM +0100, Ben Dooks wrote:

> >+  If the phy's identifier is known then the list may contain an entry
> >+  of the form: "ethernet-phy-idAAAA.BBBB" where
> >+     AAAA - The value of the 16 bit Phy Identifier 1 register as
> >+            4 hex digits. This is the chip vendor OUI bits 3:18
> >+     BBBB - The value of the 16 bit Phy Identifier 2 register as
> >+            4 hex digits. This is the chip vendor OUI bits 19:24,
> >+            followed by 10 bits of a vendor specific ID.
> >+
> 
> How about having "ethernet-phy" and adding a single property in the
> PHY node saying phy-id = <AAAABBBB>, which would be much easier to
> parse.

That option was discussed (and my first patch was this way)..

However, using the compatible string is consistent with other OF
schemes, such as PCI which uses compatible strings like pciVVVV,DDDD
pciclass,CCSS and so on.

It does make a fair amount sense because the purpose of compatible is
to identify the device.

Jason
