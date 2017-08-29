From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: r8822be: Fix typo for CONFIG_RTLWIFI_DEBUG
Date: Tue, 29 Aug 2017 16:42:16 +0200
Message-ID: <20170829144216.GA22295@kroah.com>
References: <20170829112643.GA14571@kroah.com>
 <1504006208-18965-1-git-send-email-andreas.ziegler@fau.de>
 <fcab4e04-be42-5a05-c5ad-4947d2d41164@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Ziegler <andreas.ziegler@fau.de>,
        devel@driverdev.osuosl.org,
        Yan-Hsuan Chuang <yhchuang@realtek.com>,
        Birming Chiu <birming@realtek.com>,
        netdev <netdev@vger.kernel.org>,
        Steven Ting <steventing@realtek.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:35378 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753623AbdH2OmL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 10:42:11 -0400
Content-Disposition: inline
In-Reply-To: <fcab4e04-be42-5a05-c5ad-4947d2d41164@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 09:10:10AM -0500, Larry Finger wrote:
> On 08/29/2017 06:30 AM, Andreas Ziegler wrote:
> > The debugging output in deinit_priv is guarded by an  #ifdef using
> > CONFIG_RTL_DEBUG. This symbol does not exist and should be
> > CONFIG_RTLWIFI_DEBUG instead.
> > 
> > Signed-off-by: Andreas Ziegler <andreas.ziegler@fau.de>
> 
> NACK.
> 
> Yes, there is a problem; however, CONFIG_RTLWIFI_DEBUG is not the value that
> should be used. That one is reserved for the non-staging drivers in
> drivers/net/wireless/realtek/rtlwifi/. The correct symbol for r8822be is
> CONFIG_RTLWIFI_DEBUG_ST.

Yeah, kbuild just blew up on this as well, I wonder why my local build
testing didn't see that :(

Now dropped.

greg k-h
