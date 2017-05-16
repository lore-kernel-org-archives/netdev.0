From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: Re: [PATCH v4 1/4] can: m_can: move Message RAM initialization to
 function
Date: Tue, 16 May 2017 10:00:49 +0200
Message-ID: <20170516080049.4fvo4hkj4e6v7r3v@piout.net>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
 <90788d6d-24f3-64ba-43f3-16301b777536@free-electrons.com>
 <4676456c-823c-d7db-2139-35c8229109f0@pengutronix.de>
 <1d41efe1-d24f-4700-8986-0d5dc848ea23@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
        Quentin Schulz <quentin.schulz@free-electrons.com>,
        wg@grandegger.com, mario.huettel@gmx.net,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1d41efe1-d24f-4700-8986-0d5dc848ea23@hartkopp.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 15/05/2017 at 20:51:30 -0700, Oliver Hartkopp wrote:
> On 05/15/2017 06:50 AM, Marc Kleine-Budde wrote:
> > On 05/12/2017 08:37 AM, Quentin Schulz wrote:
> > > On 05/05/2017 15:50, Quentin Schulz wrote:
> > > > To avoid possible ECC/parity checksum errors when reading an
> > > > uninitialized buffer, the entire Message RAM is initialized when probing
> > > > the driver. This initialization is done in the same function reading the
> > > > Device Tree properties.
> > > > 
> > > > This patch moves the RAM initialization to a separate function so it can
> > > > be called separately from device initialization from Device Tree.
> > > > 
> > > > Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
> > > 
> > > It's been a week since I sent this patch series. Any comments?
> > 
> > Looks good, added to linux-can-next.
> 
> Isn't this a fix for linux-can instead?
> 
> At least it would make no sense to me to have the upgraded M_CAN driver in
> Linux 4.12 without this fix.
> 

The related suspend mode on the sama5d2 is not present in v4.12 so I
think this can wait v4.13.

-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
