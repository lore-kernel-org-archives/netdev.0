From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] staging: rtlwifi: Improve debugging by using debugfs
Date: Fri, 25 Aug 2017 03:54:21 +0200
Message-ID: <20170825015421.GA8852@lunn.ch>
References: <20170824212808.26632-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
        devel@driverdev.osuosl.org, Ping-Ke Shih <pkshih@realtek.com>,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        Shaofu <shaofu@realtek.com>, Steven Ting <steventing@realtek.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43765 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754191AbdHYByZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 21:54:25 -0400
Content-Disposition: inline
In-Reply-To: <20170824212808.26632-1-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 04:28:08PM -0500, Larry Finger wrote:
> The changes in this commit are also being sent to the main rtlwifi
> drivers in wireless-next; however, these changes will also be useful for
> any debugging of r8822be before it gets moved into the main tree.
> 
> Use debugfs to dump register and btcoex status, and also write registers
> and h2c.
> 
> We create topdir in /sys/kernel/debug/rtlwifi/, and use the MAC address
> as subdirectory with several entries to dump mac_reg, bb_reg, rf_reg etc.
> An example is
>     /sys/kernel/debug/rtlwifi/00-11-22-33-44-55-66/mac_0
> 
> This change permits examination of device registers in a dynamic manner,
> a feature not available with the current debug mechanism.

Hi Larry

netdev frowns upon debugfs. You should try to keep this altogether,
making it easy to throw away before the driver is moved out of
staging.

You might want to look at ethtool -d. That will be accepted.

    Andrew
