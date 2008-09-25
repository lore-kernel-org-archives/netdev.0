From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9] PCI: add interface to set visible size of VPD
	(rev3)
Date: Thu, 25 Sep 2008 18:49:05 +0100
Message-ID: <1222364945.8641.76.camel@achroite>
References: <20080925164851.694359776@vyatta.com>
	 <20080925165223.366942933@vyatta.com>  <48DBC8D8.2080207@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <48DBC8D8.2080207@pobox.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-09-25 at 13:22 -0400, Jeff Garzik wrote:
[...]
> What is the initial size?
> 
> It seems like a bad idea to start out assuming the max, and reduce once 
> a knowledgeable driver appears.
> 
> It seems more safe to start out at zero, and let a driver increase it?

VPD is meant to be usable even without a driver - that's why it's a
(somewhat) standard capability and not device-specific.

> That way, by design, you eliminate the possibility (later, if not now) 
> of someone assuming that the full 32k can be read as soon as the 
> interface is available.

I believe that's generally true, though it may be slow.

Maybe we could read as much as we need to find the real length when the
sysfs file is first opened?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
