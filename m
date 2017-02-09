From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Thu, 09 Feb 2017 17:07:41 -0500 (EST)
Message-ID: <20170209.170741.524666868372427163.davem@davemloft.net>
References: <1486589836-53858-1-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mahesh@bandewar.net,
        linux-kernel@vger.kernel.org
To: sainath.grandhi@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486589836-53858-1-git-send-email-sainath.grandhi@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sainath Grandhi <sainath.grandhi@intel.com>
Date: Wed,  8 Feb 2017 13:37:09 -0800

> Tap character devices can be implemented on other virtual interfaces like
> ipvlan, similar to macvtap. Source code for tap functionality in macvtap
> can be re-used for this purpose.
> 
> This patch series splits macvtap source into two modules, macvtap and tap.
> This patch series also includes a patch for implementing tap character
> device driver based on the IP-VLAN network interface, called ipvtap.
> 
> These patches are tested on x86 platform.

I get rejects on patch #7 when I try to apply this to net-next,
please respin.
