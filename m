From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: smsc95xx: add reset_resume function with reset
 operation
Date: Thu, 10 Jul 2014 00:43:20 -0700 (PDT)
Message-ID: <20140710.004320.637979706845569125.davem@davemloft.net>
References: <1404960582-28096-1-git-send-email-jy0922.shim@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, steve.glendinning@shawell.net,
	drake@endlessm.com
To: jy0922.shim@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404960582-28096-1-git-send-email-jy0922.shim@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joonyoung Shim <jy0922.shim@samsung.com>
Date: Thu, 10 Jul 2014 11:49:42 +0900

> The smsc95xx needs to resume with reset operation. Otherwise it causes
> system hang by network error like below after resume. This case appears
> on odroid u3 board.
> 
> [    9.727600] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [    9.727648] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [    9.727689] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [    9.727728] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [    9.729486] PM: resume of devices complete after 2011.219 msecs
> [   10.117609] Restarting tasks ... done.
> [   11.725099] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [   13.480846] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> [   13.481361] smsc95xx 1-2:1.0 eth0: kevent 2 may have been dropped
> ...
> 
> Signed-off-by: Joonyoung Shim <jy0922.shim@samsung.com>

Applied.
