From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: HELP NEEDED!!!
Date: Mon, 04 Oct 2004 14:15:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41619336.8080805@pobox.com>
References: <BLEAIJDEHOOAGALIAAKBGEDBCCAA.pranav@nodeinfotech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev-bounce@oss.sgi.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pranav@nodeinfotech.com
In-Reply-To: <BLEAIJDEHOOAGALIAAKBGEDBCCAA.pranav@nodeinfotech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pranav wrote:
> Hi everyone,
> 
>             I have got a small problem regarding configuring my ethernet
> card,while loading the eth0 driver the kernel performs auto-probing for the
> device and configures the eth0 to half-duplex.
> 
> I used command line arguments while loading modules
> insmod 8139too io=0x280 irq=10 duplex=2

8139too module does not take any arguments like io= or irq=.  PCI cards 
do not need such parameters.

You may use ethtool to select half-duplex or full-duplex.

	Jeff
