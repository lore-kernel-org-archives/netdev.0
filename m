From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Sun, 24 May 2009 23:27:14 +0100
Message-ID: <200905242327.15139.arnd@arndb.de>
References: <4A16BAAE.3070401@grandegger.com>
	<200905231315.57016.arnd@arndb.de>
	<4A18298E.8090209@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devicetree-discuss@ozlabs.org
To: linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <4A18298E.8090209@grandegger.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Saturday 23 May 2009, Wolfgang Grandegger wrote:
> Arnd Bergmann wrote:
> > 
> > Minor nitpicking: dev->base_addr should be defined as an __iomem pointer
> > so you can avoid the cast here and in the ioremap/iounmap path.
> 
> Here the member "base_addr" of "struct net_device" is used and it's not
> up to me to change the type.

Right, that makes sense. However, most drivers use the field to store the
physical address, not the iomap token. Maybe there should be a new field
in struct sja1000_priv for the virtual address, but that would be a change
to the base driver, not just to the OF portion.

Thanks,

	Arnd <><
