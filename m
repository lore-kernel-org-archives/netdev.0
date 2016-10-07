From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: [PATCH 0/4] Introduce Juniper PTXPMB Extended driver
Date: Fri,  7 Oct 2016 18:19:30 +0300
Message-ID: <1475853574-22339-1-git-send-email-pantelis.antoniou@konsulko.com>
Cc: Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        JawaharBalaji Thirumalaisamy <jawaharb@juniper.net>,
        Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-gpio@vger.kernel.org, linux-i2c@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-watchdog@vger.kernel.org,
        netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-gpio-owner@vger.kernel.org>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Juniper's PTXPMB Extended FPGA driver. Those FPGAs
are present in Juniper's PTX series of routers.

The MFD driver provices a gpio device.

There are full device tree binding documents for the
master mfd driver and for the slave driver.

This patchset is against mainline as of today: v4.8-9431-g3477d16
and is dependent on the "Juniper prerequisites" and
"Juniper infrastructure" patchsets sent earlier.

Georgi Vlaev (2):
  mfd: ptxpmb-ext-cpld: Add documentation for PTXPMB extended CPLD
  gpio: ptxpmb-ext-cpld: Document bindings of PTXPMB extended CPLD

Guenter Roeck (2):
  mfd: ptxpmb: Add separate driver for extended CPLD
  gpio: ptxpmb-ext-cpld: Add driver for Juniper's PTXPMB extended CPLD

 .../bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt     |  36 ++
 .../bindings/mfd/jnx-ptxpmb-ext-cpld.txt           |  35 ++
 drivers/gpio/Kconfig                               |  11 +
 drivers/gpio/Makefile                              |   1 +
 drivers/gpio/gpio-ptxpmb-ext-cpld.c                | 430 +++++++++++++++++++++
 drivers/mfd/Kconfig                                |  13 +
 drivers/mfd/Makefile                               |   1 +
 drivers/mfd/ptxpmb-ext-cpld-core.c                 | 221 +++++++++++
 include/linux/mfd/ptxpmb_ext_cpld.h                |  42 ++
 9 files changed, 790 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/gpio/jnx,gpio-ptxpmb-ext-cpld.txt
 create mode 100644 Documentation/devicetree/bindings/mfd/jnx-ptxpmb-ext-cpld.txt
 create mode 100644 drivers/gpio/gpio-ptxpmb-ext-cpld.c
 create mode 100644 drivers/mfd/ptxpmb-ext-cpld-core.c
 create mode 100644 include/linux/mfd/ptxpmb_ext_cpld.h

-- 
1.9.1

