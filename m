From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 5/6] net: dsa: mv88e6060: add register defines header file
Date: Tue, 10 Nov 2015 09:49:56 -0500
Message-ID: <20151110144956.GA10654@ketchup.mtl.sfl>
References: <5641F04A.9060303@baylibre.com>
 <20151110142550.GB29568@ketchup.mtl.sfl>
 <56420268.90806@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56420268.90806@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov. Tuesday 10 (46) 03:42 PM, Neil Armstrong wrote:
> On 11/10/2015 03:25 PM, Vivien Didelot wrote:
> > Hi Neil,
> > 
> > On Nov. Tuesday 10 (46) 02:25 PM, Neil Armstrong wrote:
> >> To align with the mv88e6xxx code, add a similar header file
> >> with all the register defines.
> >> The file is based on the mv88e6xxx header for coherency.
> >>
> >> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> > 
> > In the RFC patchset, Andrew mentioned that there is not that much things in
> > common with mv88e6xxx, so I don't really see a value to add a separate header
> > file. Would that make sense to you guys to add the defines directly in
> > mv88e6060.c and squash that in the last patch?
> > 
> >> ---
> >>  drivers/net/dsa/mv88e6060.h | 108 ++++++++++++++++++++++++++++++++++++++++++++
> >>  1 file changed, 108 insertions(+)
> >>  create mode 100644 drivers/net/dsa/mv88e6060.h
> >>
> >> diff --git a/drivers/net/dsa/mv88e6060.h b/drivers/net/dsa/mv88e6060.h
> >> new file mode 100644
> >> index 0000000..adbc894
> >> --- /dev/null
> >> +++ b/drivers/net/dsa/mv88e6060.h
> >> @@ -0,0 +1,108 @@
> >> +/*
> >> + * net/dsa/mv88e6060.h - Marvell 88e6060 switch chip support
> >> + * Copyright (c) 2008 Marvell Semiconductor
> > 
> > Also I don't think the copyright notice is correct here.
> > 
> > Thanks,
> > -v
> > 
> Vivien,
> 
> Is something like this OK ?

I'd say yes.

> /*
>  * drivers/net/dsa/mv88e6060.h - Marvell 88e6060 switch chip support
>  * Copyright (c) 2015 Neil Armstrong
>  *
>  * Based on mv88e6xxx.h
>  * Copyright (c) 2008 Marvell Semiconductor
>  *
>  * This program is free software; you can redistribute it and/or modify
>  * it under the terms of the GNU General Public License as published by
>  * the Free Software Foundation; either version 2 of the License, or
>  * (at your option) any later version.
>  */

Thanks Neil,
-v
