From: "Michael Chan" <mchan@broadcom.com>
Subject: RE: [PATCH 2.6.10] tg3: Fix TSO for 5750
Date: Mon, 24 Jan 2005 14:59:43 -0800
Message-ID: <B1508D50A0692F42B217C22C02D84972020F3D44@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:

> If we've created this new TG3_FLG2_HW_TSO flag, we should 
> eliminate all 5750 tests which are just checking for that.
> 
> For example, this patch leaves the following test:
> 
> -		if (GET_ASIC_REV(tp->pci_chip_rev_id) == 
> ASIC_REV_5705) {
> +		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO) ||
> +		    (GET_ASIC_REV(tp->pci_chip_rev_id) == 
> ASIC_REV_5705)) {
> 
> Here, just checking the TG3_FLG3_HW_TSO flag would suffice.
> 
> 
> 

This particular test is for 5705 or 5750. 5705 is a little different from
5750 in terms of TSO.

But I plan to introduce another flag for 5705 and 5750 as these 2 chips have
other things in common. This will be done in a different patch.

Michael
