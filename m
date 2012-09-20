From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] USB: remove dbg() usage in USB networking drivers
Date: Thu, 20 Sep 2012 17:53:35 -0400 (EDT)
Message-ID: <20120920.175335.1128494030737237412.davem@davemloft.net>
References: <1348077212.22122.13.camel@joe2Laptop>
	<20120919193536.GA13933@kroah.com>
	<20120919194614.GA17585@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120919194614.GA17585@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Wed, 19 Sep 2012 20:46:14 +0100

> From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> 
> The dbg() USB macro is so old, it predates me.  The USB networking drivers are
> the last hold-out using this macro, and we want to get rid of it, so replace
> the usage of it with the proper netdev_dbg() or dev_dbg() (depending on the
> context) calls.
> 
> Some places we end up using a local variable for the debug call, so also
> convert the other existing dev_* calls to use it as well, to save tiny amounts
> of code space.
> 
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
> v2: Addressed review comments from Joe Perches
> 
> Again, I am glad to take this in the usb-next tree if wanted, whatever is
> easiest.

I'll take this into net-next, applied, thanks Greg.
