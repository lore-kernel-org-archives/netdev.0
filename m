From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: fec: add post PHY reset delay DT property
Date: Tue, 23 May 2017 14:52:14 +0200
Message-ID: <20170523125214.GW13759@lunn.ch>
References: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan@nxp.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 11:48:08AM +0200, Quentin Schulz wrote:
> Some PHY require to wait for a bit after the reset GPIO has been
> toggled. This adds support for the DT property `phy-reset-post-delay`
> which gives the delay in milliseconds to wait after reset.
> 
> If the DT property is not given, no delay is observed. Post reset delay
> greater than 1000ms are invalid.
> 
> Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
