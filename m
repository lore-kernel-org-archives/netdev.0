From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] using mii-bitbang on different processor ports -	update
	the booting-without-of.txt-file
Date: Thu, 08 Nov 2007 14:20:45 -0600
Message-ID: <47336F9D.8060405@freescale.com>
References: <1194339117.3467.8.camel@p60635-ste.ids.de>	
	<20071106184649.GA5283@loki.buserror.net>
	<1194442844.3571.14.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1194442844.3571.14.camel@p60635-ste.ids.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Sergej Stepanov wrote:
> If both mdio and mdc controlling pins are on the same processor port,
> one resource should be used.
> Otherwise, two resources are used: the 1-st - mdio, the 2-nd - mdc.

How about:
The first reg resource is the I/O port register block on which MDIO 
resides.  The second reg resource is the I/O port register block on 
which MDC resides.  If there is only one reg resource, it is used for 
both MDIO and MDC.

We also need to change the reference to port C in fsl,mdio-pin and 
fsl,mdc-pin.

-Scott
