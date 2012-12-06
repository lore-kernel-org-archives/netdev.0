From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: workaround for missing extended GigaMAC
 registers
Date: Thu, 6 Dec 2012 15:38:42 +0800
Message-ID: <20121206073842.GA3847@udknight>
References: <20121205223452.GA24164@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Lee Chun-Yi <jlee@suse.com>, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:48108 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab2LFHig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 02:38:36 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2662482dak.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 23:38:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121205223452.GA24164@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2012 at 11:34:52PM +0100, Francois Romieu wrote:
> GigaMAC registers have been reported left unitialized in several
> situations:
> - after cold boot from power-off state
> - after S3 resume
> 
> Tweaking rtl_hw_phy_config takes care of both.
Hi Francois.
Are you sure we will lost GigaMAC registers's content
after NIC into PCI_D3hot state?

Thanks
