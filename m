From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH]realtek:r8169: Bugfix or workaround for missing extended
 GigaMAC registers settings
Date: Fri, 30 Nov 2012 18:00:02 +0800
Message-ID: <20121130100002.GA6253@udknight>
References: <20121130050619.GA12862@udknight>
 <20121130063500.GA9436@electric-eye.fr.zoreil.com>
 <20121130090429.GA14439@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Francois Romieu <romieu@fr.zoreil.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36977 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756938Ab2K3KAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 05:00:42 -0500
Content-Disposition: inline
In-Reply-To: <20121130090429.GA14439@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2012 at 05:04:29PM +0800, Wang YanQing wrote:
> On Fri, Nov 30, 2012 at 07:35:00AM +0100, Francois Romieu wrote:
> > Which kernel version is it ?
> I have done the test and debug  with mainline 
> e23739b4ade80a3a7f87198f008f6c44a7cbc9fd, v3.7-rc7-51-ge23739b
More exactly, I find the problem in 3.0 stable tree, and fix it
for 3.0 stable tree first, then re test and debug for mainline,
e23739b4ade80a3a7f87198f008f6c44a7cbc9fd, v3.7-rc7-51-ge23739b.

I found the mainline's r8169 works the same as realtek's driver,
the first time don't work, but it works after reboot, the reason
is the pci driver's shutdown don't call rtl_rar_set in 3.0 stable
tree but the mainline does.

Thanks.
