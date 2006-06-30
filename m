From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'zd1211rw' branch of wireless-2.6 (new driver)
Date: Fri, 30 Jun 2006 12:29:30 -0400
Message-ID: <44A5516A.3000602@garzik.org>
References: <20060626212547.GE30706@tuxdriver.com> <20060628004838.GA15906@tuxdriver.com> <20060628173613.GC18914@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:13499 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932100AbWF3Q3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 12:29:36 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060628173613.GC18914@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> For easier review, a tarball of drivers/net/wireless/zd1211rw is available here:
> 
> 	http://www.kernel.org/pub/linux/kernel/people/linville/zd1211rw.tar.gz
> 
>>From Daniel's initial zd1211rw changelog:
> 
>     [PATCH] ZyDAS ZD1211 USB-WLAN driver
> 
>     There are 60+ USB wifi adapters available on the market based on the ZyDAS
>     ZD1211 chip.
> 
>     Unlike the predecessor (ZD1201), ZD1211 does not have a hardware MAC, so most
>     data operations are coordinated by the device driver. The ZD1211 chip sits
>     alongside an RF transceiver which is also controlled by the driver. Our driver
>     currently supports 2 RF types, we know of one other available in a few marketed
>     products which we will be supporting soon.
> 
>     Our driver also supports the newer revision of ZD1211, called ZD1211B. The
>     initialization and RF operations are slightly different for the new revision,
>     but the main difference is 802.11e support. Our driver does not support the
>     QoS features yet, but we think we know how to use them.
> 
>     This driver is based on ZyDAS's own GPL driver available from www.zydas.com.tw.
>     ZyDAS engineers have been responsive and supportive of our efforts, so thumbs
>     up to them. Additionally, the firmware is redistributable and they have
>     provided device specs.
> 
>     This driver has been written primarily by Ulrich Kunitz and myself. Graham
>     Gower, Greg KH, Remco and Bryan Rittmeyer have also contributed. The
>     developers of ieee80211 and softmac have made our lives so much easier- thanks
> 
>     We maintain a small info-page: http://zd1211.ath.cx/wiki/DriverRewrite
> 
>     If there is enough time for review, we would like to aim for inclusion in
>     2.6.18. The driver works nicely as a STA, and can connect to both open and
>     encrypted networks (we are using software-based encryption for now). We will
>     work towards supporting more advanced features in the future (ad-hoc, master
>     mode, 802.11a, ...).
> 
> Please review!
> 
> Thanks,
> 
> John
> 
> ---
> 
> The following changes since commit 70a332b048e4d90635dfa47fc5d91cf87b5cc3a5:
>   John W. Linville:
>         softmac: fix build-break from 881ee6999d66c8fc903b429b73bbe6045b38c549
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git zd1211rw

pulled, though I would like to see the debug facilities cleaned up


