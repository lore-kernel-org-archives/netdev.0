From: Grant Grundler <iod00d@hp.com>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP 16-way)
Date: Tue, 31 May 2005 11:36:53 -0700
Message-ID: <20050531183653.GF20793@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972020F3CED@NT-IRVA-0741.brcm.ad.broadcom.com> <20050531153819.GA20793@esmail.cup.hp.com> <1117560157.4310.16.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Peter Chubb <peterc@gelato.unsw.edu.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1117560157.4310.16.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 10:22:37AM -0700, Michael Chan wrote:
> > Michael,
> > Peter bounced this email to me after we talked about issues he was
> > having with the rx8620 (HP 16-way ia64, sx1000 chipset) "IOX Core LAN".
> > It sounded like the same problem I tracked down with rx8620 IOX Core LAN
> > in March.  Here is the summary :
> > 
> > | In May, 2004,  tg3 v3.4 changed how MAC_LED_CTRL (0x40c) was getting
> > | programmed and how to determine what to program into LED_CTRL. The new
> > | code trusted NIC_SRAM_DATA_CFG (0x00000b58) to indicate what to write
> > | to LED_CTRL and MII EXT_CTRL registers. On "IOX Core Lan", SRAM was
> > | saying MODE_MAC (0x0) and that doesn't work.
> > 
> 
> Thanks Grant, I'll chase this down and find a solution to this problem.

You mean you'll help find a way to reflash the onboard eeprom?

thanks,
grant
