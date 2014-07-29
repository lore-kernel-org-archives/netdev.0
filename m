From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/bas_gigaset: fix a leak on failure path in
 gigaset_probe()
Date: Tue, 29 Jul 2014 12:18:56 -0700 (PDT)
Message-ID: <20140729.121856.1236100223837303806.davem@davemloft.net>
References: <1406327671-28271-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406327671-28271-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 26 Jul 2014 02:34:31 +0400

> There is a lack of usb_put_dev(udev) on failure path in gigaset_probe().
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied, thanks.
