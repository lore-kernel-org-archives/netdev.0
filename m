From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 4/8] tg3: Add msi test
Date: Tue, 22 Mar 2005 15:57:35 -0500
Message-ID: <424086BF.6030300@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E24@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E24@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add an MSI test to make sure MSI is working at the system level. If the test
> fails, the driver will go back to INTx mode.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com

In theory, this patch is not necessary.

pci_enable_msi() should fail, if MSI is not available at the system level.

What behavior are you seeing?

	Jeff
