From: thockin@hockin.org
Subject: Re: [patch 1/4] natsemi: Add support for using MII port with no PHY
Date: Sun, 12 Mar 2006 13:41:13 -0800
Message-ID: <20060312214113.GA15071@hockin.org>
References: <20060312192259.929734000@mercator.sirena.org.uk> <20060312205303.869316000@mercator.sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932258AbWCLVhr@vger.kernel.org>
To: Mark Brown <broonie@sirena.org.uk>
Content-Disposition: inline
In-Reply-To: <20060312205303.869316000@mercator.sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 12, 2006 at 07:23:00PM +0000, Mark Brown wrote:
> This patch provides a module option which configures the natsemi driver
> to use the external MII port on the chip but ignore any PHYs that may be
> attached to it.  The link state will be left as it was when the driver
> started and can be configured via ethtool.  Any PHYs that are present
> can be accessed via the MII ioctl()s.
> 
> This is useful for systems where the device is connected without a PHY
> or where either information or actions outside the scope of the driver
> are required in order to use the PHYs.

Not that my opinion should hold much weight, having been absent from the
driver for some time, but yuck.  Is there no better way to do this thatn
sprinkling poo all over it?
