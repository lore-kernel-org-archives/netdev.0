From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] net: usb: allow MTU that is a multiple of USB packet
 size
Date: Thu, 07 May 2015 12:11:17 +0200
Message-ID: <1430993477.30151.6.camel@suse.de>
References: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ruslan Bilovol <ruslan.bilovol@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430992159-27783-1-git-send-email-ruslan.bilovol@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-07 at 12:49 +0300, Ruslan Bilovol wrote:
> Current usbnet driver rejects setting MTU that is a multiple
> of USB endpoint's wMaxPacketSize size. However, it may only
> lead to possible performance degradation but is not so
> critical that its using should be prohibited. So allow it
> but also warn user about possible issue.

We have reports about devices reacting badly to ZLPs.
Unless you have a compelling reasons for this change
I have to reject it.

	Regards
		Oliver

NACK
