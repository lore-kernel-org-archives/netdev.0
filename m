From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 2/8] tg3: flush status block in tg3_interrupt
Date: Tue, 22 Mar 2005 15:53:29 -0500
Message-ID: <424085C9.3020608@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E22@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E22@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add register read of PCI state register in tg3_interrupt() if status block's
> updated bit is not set. This will flush the status block and confirm whether
> the interrupt is ours or not. PCI ordering rules allow the interrupt to
> arrive at the CPU ahead of the status block that may be posted at the
> chipset.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com

ACK
