From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 2/2] phylib: make mdio-gpio work without OF (v4)
Date: Thu, 20 Nov 2008 17:24:18 +0100
Message-ID: <200811201724.18731.laurentp@cse-semaphore.com>
References: <20081114102336.11513.67767.stgit@Programuotojas.82-135-208-232.ip.zebra.lt> <20081114102433.11513.2557.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Mike Frysinger <vapier.adi@gmail.com>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20081114102433.11513.2557.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Content-Disposition: inline
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 November 2008 11:24:34 Paulius Zaleckas wrote:
> make mdio-gpio work with non OpenFirmware gpio implementation.
>
> Aditional changes to mdio-gpio:
> - use gpio_request() and gpio_free()
> - place irq[] array in struct mdio_gpio_info
> - add module description, author and license
> - add note about compiling this driver as module
> - rename mdc and mdio function (were ugly names)
> - change MII to MDIO in bus name
> - add __init __exit to module (un)loading functions
> - probe fails if no phys added to the bus
> - kzalloc bitbang with sizeof(*bitbang)
>
> Changes since v3:
> - keep bus naming "%x" to be compatible with existing drivers.
>
> Changes since v2:
> - more #ifdefs reduction
> - platform driver will be registered on OF platforms also
> - unified platform and OF bus_id to phy%i
>
> Changes since v1:
> - removed NO_IRQ
> - reduced #idefs
>
> Laurent, please test this driver under OF.

No obvious issue found.

Acked-by: Laurent Pinchart <laurent.pinchart@skynet.be>

> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Cc: Laurent Pinchart <laurent.pinchart@skynet.be>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Mike Frysinger <vapier.adi@gmail.com>

-- 
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
F +32 (2) 387 42 75
