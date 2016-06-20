From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] net: macb: Add gmii2rgmii converter support
Date: Sun, 19 Jun 2016 22:39:04 -0700
Message-ID: <5F581884-194F-46BD-98E4-A3DAE17A2A7C@gmail.com>
References: <1466400437-21277-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	nicolas.ferre@atmel.com, punnaia@xilinx.com, harinik@xilinx.com,
	anirudh@xilinx.com, michals@xilinx.com, appanad@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466400437-21277-1-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On June 19, 2016 10:27:17 PM MST, Kedareswara rao Appana <appana.durga.rao@xilinx.com> wrote:
>This patch adds support for gmii2rgmii converter
>in the macb driver.
>
>The GMII to RGMII IP core provides the
>Reduced Gigabit Media Independent Interface
>(RGMII) between Ethernet physical media devices
>And the Gigabit Ethernet controller.
>This core can switch dynamically between the
>Three different speed modes of operation (10/100/1000 Mb/s).
>MDIO interface is used to set operating speed of Ethernet MAC.
>
>Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>---
>--> Tried to include this Coverter support in the
>PHY layer but it won't fit into the PHY framework as the
>coverter won't have vaild vendor/Device id registers.
>--> The Converter has only one register (16) that need's
>to be programmed with the external phy negotiated speed.
>--> The converter won't follow the Standard MII(ieee 802.3 clause 22).
>--> Will appreciate if someone can help on adding this coverter support

With the fixed PHY emulated PHY and registering a link_update callback (see drivers/net/dsa/bcm_sf2.c for an example), you could read specific registers which indicates link parameters and update the PHY device with these. 

How exactly is this converter working?

-- 
Florian
