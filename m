From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: Fix error path in open function
Date: Sun, 13 Nov 2016 12:03:49 -0500 (EST)
Message-ID: <20161113.120349.394151836949728811.davem@davemloft.net>
References: <1478749885-32212-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478749885-32212-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed,  9 Nov 2016 19:51:25 -0800

> If usb_submit_urb() called from the open function fails, the following
> crash may be observed.
 ...
> Clean up error handling to avoid registering the notifier if the open
> function is going to fail.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Looks good, applied, thanks.
