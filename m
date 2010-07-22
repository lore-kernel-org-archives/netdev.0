From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sysfs: add attribute to indicate hw address
 assignment type
Date: Thu, 22 Jul 2010 15:07:23 +0100
Message-ID: <1279807643.2104.1.camel@achroite.uk.solarflarecom.com>
References: <4C458CB7.3030508@redhat.com>	<4C458F50.4070200@ixiacom.com>
	 <4C4593DA.9040207@redhat.com>
	 <20100720.131839.134093789.davem@davemloft.net>
	 <4C46AB60.5060008@redhat.com>
	 <1279720478.2089.3.camel@achroite.uk.solarflarecom.com>
	 <4C483E8D.4080300@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, abadea@ixiacom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: Stefan Assmann <sassmann@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C483E8D.4080300@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-07-22 at 14:50 +0200, Stefan Assmann wrote:
> On 21.07.2010 15:54, Ben Hutchings wrote:
> > On Wed, 2010-07-21 at 10:10 +0200, Stefan Assmann wrote:
> >> I put Alex' idea into code for further discussion, keeping the names
> >> mentioned here until we agree on the scope of this attribute. When we
> >> have settled I'll post a patch with proper patch description.
> > [...]
> > 
> > Just a little nitpick: I think it would be clearer to use a more
> > specific term like 'address source' or 'address assignment type' rather
> > than 'address type'.
> 
> Here's a proposal for the final patch.

Looks good, but...

[...]
>  /**
> + * dev_hw_addr_random - Create random MAC and set device flag
> + * @dev: pointer to net_device structure
> + * @addr: Pointer to a six-byte array containing the Ethernet address
> + *
> + * Generate random MAC to be used by a device and set addr_assign_type
> + * so the state can be read by sysfs and be used by udev.
> + */
> +static inline void dev_hw_addr_random(struct net_device *dev, u8 *hwaddr)
> +{
> +	dev->addr_assign_type |= NET_ADDR_RANDOM;
> +	random_ether_addr(hwaddr);
> +}
[...]

...why '|=' and not '='?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
