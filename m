From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:11:06 -0500
Message-ID: <1217520666.3657.37.camel@calx>
References: <20080730.145727.07367670.davem@davemloft.net>
	 <20080730151316.a4d76fe9.akpm@linux-foundation.org>
	 <1217500776.3454.136.camel@pmac.infradead.org>
	 <20080731.034737.154058020.davem@davemloft.net>
	 <1217518591.3657.27.camel@calx>  <20080731085916.232f4c31@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, jeff@garzik.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:50929 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751064AbYGaQNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 12:13:43 -0400
In-Reply-To: <20080731085916.232f4c31@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-31 at 08:59 -0700, Stephen Hemminger wrote:
> I have no problem with an embedded CONFIG_ETHTOOL that normal users
> can ignore. Just don't expect the network developers to fix things
> that are broken when CONFIG_ETHTOOL is not enabled. I.e if embedded
> build is broken it is your problem.

menuconfig EMBEDDED
        bool "Configure standard kernel features (for small systems)"
        help
          This option allows certain base kernel options and settings
          to be disabled or tweaked. This is for specialized
          environments which can tolerate a "non-standard" kernel.
          Only use this if you really know what you are doing.

If you think that disclaimer needs to be bigger, let me know.

-- 
Mathematics is the supreme nostalgia of our time.

