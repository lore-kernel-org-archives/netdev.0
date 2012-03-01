From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Thu, 1 Mar 2012 20:05:58 +0100
Message-ID: <20120301190558.GB12450@electric-eye.fr.zoreil.com>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org> <20111230.172211.188260740088628815.davem@davemloft.net> <20111231121704.GA9842@electric-eye.fr.zoreil.com> <20120103233046.GD8563@electric-eye.fr.zoreil.com> <CA+iF6RocEBdXZh6LGW_Xak0Vxnzx6=AROvQJbF7sQzc7vYEb6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Todd Broch <tbroch@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47615 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756467Ab2CATG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 14:06:26 -0500
Content-Disposition: inline
In-Reply-To: <CA+iF6RocEBdXZh6LGW_Xak0Vxnzx6=AROvQJbF7sQzc7vYEb6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Todd Broch <tbroch@chromium.org> :
> Thanks for suggestion and patch.  Tried it on system I have and it did not
> place device in runtime suspend (D3) from initialization.  It appears that
> pm_schedule_suspend returns an error (-11, EAGAIN?).  Going to investigate
> more today and will comment further then.

Did you find anything new ?

If I insert the r8169 module then enable runtime PM control on an unused
r8169 device (no cable, never brought up), rtl8169_runtime_suspend is 
called. Same thing when runtime PM control is enabled before the module
is inserted.

I would not mind http://patchwork.ozlabs.org/patch/133590/ going
'Not Applicable' :o)

-- 
Ueimor
