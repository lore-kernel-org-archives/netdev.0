From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] propogate errors from misc_register to caller
Date: Thu, 19 Feb 2004 16:23:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220002328.GE16267@kroah.com>
References: <20040213102755.27cf4fcd.shemminger@osdl.org> <20040213112100.4f42abc2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tommi Virtanen <tv@tv.debian.net>, Leann Ogasawara <ogasawara@osdl.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040213112100.4f42abc2@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2004 at 11:21:00AM -0800, Stephen Hemminger wrote:
> The patch to check for / in class_device is not enough.
> The misc_register function needs to check return value of the things it calls!

Applied to my trees, thanks.

greg k-h
