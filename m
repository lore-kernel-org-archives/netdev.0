From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
Date: Mon, 20 Feb 2017 17:37:14 +0100
Message-ID: <20170220163714.uj5el22c5tq47cul@piout.net>
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
 <b1140be9-1811-1512-b32e-436e8bb25824@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        fvallee@eukrea.fr, wg@grandegger.com, mkl@pengutronix.de,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com,
        nicolas.ferre@atmel.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b1140be9-1811-1512-b32e-436e8bb25824@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/02/2017 at 16:37:50 +0100, Oliver Hartkopp wrote:
> Fortunately I was contacted by Bosch this Friday as they want to contribute
> a driver upgrade to support IP cores up to 3.2.x.
> Additionally their plan is to use Device Tree information to determine the
> IP core revision - or at least to cross check its information with the
> register information used in your suggestion.

My opinion is that is is not really useful. Either we use the version
info from the register or DT. But that is probably a matter of taste and
you are the maintainer :)

> For that reason I would suggest to wait for the driver updates from Bosch
> instead of adding an incomplete fix for only one change of eleven.
> 

Well, having something working right now is still better that nothing. I
think it is worth having that patch now so CAN is working on our
platforms.

Everything else can probably be built on top of it anyway.

-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
