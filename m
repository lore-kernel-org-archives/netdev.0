From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 5/5] Add KSZ8795 SPI driver
Date: Fri, 8 Sep 2017 20:37:29 +0200
Message-ID: <20170908183729.GK25219@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A95@CHN-SV-EXMX02.mchp-main.com>
 <20170908092614.GB18365@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E1C@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E1C@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Sorry about the formatting.  It seems my e-mail system needs to be checked
> to make sure it does not auto-format the contents again.

I've never seen issues like this with git send-email. Please use
it. Email problems generally happen with the client, not the
backend. What client did you use to send these patches?

> About the SPI access functions they are the same for each driver except the
> low level ksz_spi_read_reg and ksz_spi_write_reg.  The dev_io_ops structure
> should contain only those 2 and ksz_spi_get and ksz_spi_set.
> 
> But that requires changing ksz_spi.c.  The idea was to keep the code of
> KSZ9477 driver with little change as possible while introducing another driver.

Maintainability is always the primary goal. If you need to change the
KSZ9477 code to make the whole more maintainable, do so. Just make it
lots of small, easy to review, obviously correct changes.

     Andrew
