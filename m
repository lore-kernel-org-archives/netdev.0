From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Sat, 23 May 2009 18:51:26 +0200
Message-ID: <4A18298E.8090209@grandegger.com>
References: <4A16BAAE.3070401@grandegger.com>
	<200905231315.57016.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org,
	linuxppc-dev <Linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
In-Reply-To: <200905231315.57016.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-mnsaURCQ41sdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-mnsaURCQ41sdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-mnsaURCQ41sdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> On Friday 22 May 2009, Wolfgang Grandegger wrote:
>> This patch adds a generic driver for SJA1000 chips on the OpenFirmware
>> platform bus found on embedded PowerPC systems. 
> 
> Nice driver!
> 
>> +static u8 sja1000_ofp_read_reg(const struct net_device *dev, int reg)
>> +{
>> +	return in_8((void __iomem *)(dev->base_addr + reg));
>> +}
>> +
>> +static void sja1000_ofp_write_reg(const struct net_device *dev, int reg, u8 val)
>> +{
>> +	out_8((void __iomem *)(dev->base_addr + reg), val);
>> +}
> 
> Minor nitpicking: dev->base_addr should be defined as an __iomem pointer
> so you can avoid the cast here and in the ioremap/iounmap path.

Here the member "base_addr" of "struct net_device" is used and it's not
up to me to change the type.

Wolfgang.
