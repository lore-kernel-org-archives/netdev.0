From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: respin of hso patches for linux-2.6.28-rc6 hso_mutex.patch
 [patch 4/6]
Date: Tue, 25 Nov 2008 00:34:27 -0800 (PST)
Message-ID: <20081125.003427.90695589.davem@davemloft.net>
References: <492ABECF.5050307@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <492ABECF.5050307-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Mon, 24 Nov 2008 15:48:47 +0100

> A new structure hso_mutex_table had to be declared statically
> & used as as hso_device mutex_lock(&serial->parent->mutex) etc
> is freed in hso_serial_open & hso_serial_close by kref_put while
> the mutex is still in use.
> This is a substantial change but should make the driver much stabler.
> Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Applied, but I had to fixup a lot of whitespace errors.

All the lines that add code had a single initial space and
then tabs.

I know where this comes from.  You applied the patch to your
tree, there were rejects, and you copied and pasted the hunks
from the foo.rej file into the source file.

In doing so you left the initial space character that sits
after each "+" in the foo.rej file.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
