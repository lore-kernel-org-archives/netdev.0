From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFR] gianfar ethernet driver
Date: Mon, 19 Jul 2004 21:13:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090286009.4149.12.camel@localhost.localdomain>
References: <C681B01E-CEA9-11D8-931F-000393DBC2E8@freescale.com>
	 <2A724364-D53A-11D8-8835-000393C30512@freescale.com>
	 <40F4A6E5.4060000@pobox.com>
	 <85DC52B0-D9DB-11D8-AE55-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Andy Fleming <AFLEMING@motorola.com>,
        netdev@oss.sgi.com, Kumar Gala <kumar.gala@motorola.com>,
        hadi@cyberus.ca, rmk@arm.linux.org.uk, benh@kernel.crashing.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <85DC52B0-D9DB-11D8-AE55-000393C30512@freescale.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-19 at 18:29 -0500, Andy Fleming wrote:
> > I could have sworn OCP does struct device these days.  If not, poke 
> > the platform people.
> 
> Ah, I found it.  ocpdev->dev.  Done.

So we have BenH talking about pre-populating sysfs with objects for all
the on-chip peripherals and metadata like MAC addresses. We have some
PPC platforms using 'OCP' which does much the same thing, and ARM
platforms using yet another implementation. Some drivers support more
than one of these.

I suspect we need to bash some heads together... :)

-- 
dwmw2
