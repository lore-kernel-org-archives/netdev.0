From: Igor Plyatov <plyatov@gmail.com>
Subject: Re: [PATCH v2] net: phy: workaround for buggy cable detection by
 LAN8700 after cable plugging
Date: Fri, 14 Aug 2015 20:12:15 +0300
Message-ID: <55CE216F.6000806@gmail.com>
References: <1439493514-10793-1-git-send-email-plyatov@gmail.com> <5164251.N6KMl6pkAR@kerker> <55CDA0B8.5000200@gmail.com> <3066235.RJEkKeJLOx@kerker>
Reply-To: plyatov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	f.fainelli@gmail.com, joe@perches.com, luwei.zhou@freescale.com,
	richardcochran@gmail.com, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, Fabio.Estevam@freescale.com,
	LW@karo-electronics.de, Frank.Li@freescale.com
To: Michael Heimpold <mhei@heimpold.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3066235.RJEkKeJLOx@kerker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Michael,

> The LAN8700, LAN8710, LAN8720 is a product of the SMSC company.
> Microchip acquired SMSC in August 2012.
>
> The LAN8700 is a legacy product for Microchip and they will not update
> anything about it. So, even if Microchip know about HW bug, then there
> is no chance to have Errata sheet or any new documents about LAN8700.
> Long time ago, I worked on a custom device with a PHY of the same family.
> Errata sheet existed but was only available by signing a NDA. So I simply
> wondered whether this changed since SMSC is now Microchip or if they keep
> it still so covered...

The Microchip web-site does not contain Errata sheet for LAN87xx devices.
While it contains many Errata sheets for PIC and dsPIC devices.
So, situation is same as many years ago.


> I propose following comment for the lan87xx_read_status():
> /*
>    * The LAN87xx suffers from rare absence of the ENERGYON-bit when
> Ethernet cable
>    * plugs in while LAN87xx is in Energy Detect Power-Down mode. This
> leads to
>    * unstable detection of plugging in Ethernet cable.
>    * This workaround disables Energy Detect Power-Down mode and waiting for
>    * response on link pulses to detect presence of plugged Ethernet cable.
>    * The Energy Detect Power-Down mode enabled again in the end of
> procedure to
>    * save approximately 220 mW of power if cable is unplugged.
>    */
> Nice. Only one nitpick: ... _is_ enabled again...
>

Changed in [PATCH v3].

Best wishes.
--
Igor Plyatov
