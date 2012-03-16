From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Replace IS_ENABLED(CONFIG_FCOE) in linux/netdevice.h
Date: Fri, 16 Mar 2012 00:55:45 +0000
Message-ID: <1331859345.2424.38.camel@bwh-desktop.uk.solarflarecom.com>
References: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, <devel@open-fcoe.org>,
	<netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Tony Breeds <tony@bakeyournoodle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-03-16 at 11:30 +1100, Tony Breeds wrote:
> On platforms that (or configs that do not have PCI support building any
> code that includes linux/netdevice.h we see the following warnings:
> 
> include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE" is not defined [-Wundef]
> include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE_MODULE" is not defined [-Wundef]
> 
> In the case of this file we can trivially fallback to the old school
>  #if defined(...) syntax.
[...]

The script that generates those symbols should be fixed instead.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
