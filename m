From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 02/29] wimax: headers for kernel API and user space
	interaction
Date: Wed, 17 Dec 2008 09:44:45 -0800
Message-ID: <200812170944.45910.inaky@linux.intel.com>
References: <cover.1229345769.git.inaky@linux.intel.com>
	<b0f6aee9c3e6de399e9a29e2c6a9ab3c1017b0d0.1229345776.git.inaky@linux.intel.com>
	<494723F4.8020707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org, greg@kroah.com
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <494723F4.8020707@cn.fujitsu.com>
Content-Disposition: inline
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

On Monday 15 December 2008, Wang Chen wrote:
> Inaky Perez-Gonzalez said the following on 2008-12-15 20:57:
> > + * Usage:
> > + *  1. Embed a &struct wimax_dev at *the beginning* the network
> > + *     device structure so that net_dev->priv points to it.
> > + *
>
> There is no net_device->priv anymore in net-next tree.

You are right -- need to update this documentation to refer to 
netdev_priv() [it is how it is used, anyway].

Thanks,

-- 
Inaky
