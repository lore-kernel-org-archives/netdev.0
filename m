From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] netconsole: Add tty driver
Date: Tue, 01 Apr 2014 17:37:26 -0400 (EDT)
Message-ID: <20140401.173726.1757895946889652328.davem@davemloft.net>
References: <533B2F03.6060008@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	schwab@linux-m68k.org, netdev@vger.kernel.org, nikolay@redhat.com,
	andy.shevchenko@gmail.com, gregkh@linuxfoundation.org,
	jiri@resnulli.us, joe@perches.com, alonid@postram.com
To: struan.bartlett@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533B2F03.6060008@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Struan Bartlett <struan.bartlett@gmail.com>
Date: Tue, 01 Apr 2014 23:26:27 +0200

> Adds tty driver to netconsole module. When module is loaded,
> creates /dev/netcon0 device and enables support for console=netcon0
> kernel cmdline option, causing /dev/console output to be sent to
> /dev/netcon0. This allows startup/shutdown script output from
> headless platforms to be logged over (secure) network.
> 
> To: Matt Mackall <mpm@selenic.com>
> Signed-off-by: Struan Bartlett <struan.bartlett@gmail.com>
> ---
> 
> Changes since v1:
>  * Fixed whitespace mangled by broken mailer

It's still not submitted cleanly, look at what it looks like
in patchwork:

http://patchwork.ozlabs.org/patch/336171/
