From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Thu, 6 Jan 2005 09:13:55 -0800
Message-ID: <20050106171355.GB6539@gate.ebshome.net>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>,
        Kumar Gala <kumar.gala@freescale.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
Content-Disposition: inline
In-Reply-To: <20050106070245.GA6539@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 05, 2005 at 11:02:45PM -0800, Eugene Surovegin wrote:
> 5) PHY interrupt sharing looks broken. Although you request_irq using 
> SA_SHIRQ flag, in the handler itself you don't detect whether this 
> interrupt is for this PHY or not, and return IRQ_HANDLED. This will 
> result in first registered PHY hijacking IRQs from other PHYs (or 
> devices) sharing the same IRQ line.

Doh, ignore this. I wasn't thinking straight...

--
Eugene
