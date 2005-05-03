From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Mystery packet killing tg3
Date: Tue, 03 May 2005 14:28:10 -0700
Message-ID: <1115155690.15156.32.camel@rh4>
References: <20050502162405.65dfb4a9@localhost.localdomain>
 <20050502200251.38271b61.davem@davemloft.net>
 <20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
 <20050503141314.441c9d75.davem@davemloft.net>
 <1115152907.15156.26.camel@rh4>
 <20050503150333.1ac1c159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503150333.1ac1c159.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-03 at 15:03 -0700, David S. Miller wrote:

> Michael, there were no master/target abort bits set in the PCI status
> register from his dump.  If one of the DMA units locks up on the tg3,
> will it still be able to update the PCI_STATUS register appropriately
> when it encounters a DMA transaction error (ie. master or target abort)

I believe so. Also, the DMA read and write status registers showed all
zeros, meaning there were no DMA related errors:

DEBUG: RDMAC_MODE[000003fc] RDMAC_STATUS[00000000]
DEBUG: WDMAC_MODE[000003fc] WDMAC_STATUS[00000000]
