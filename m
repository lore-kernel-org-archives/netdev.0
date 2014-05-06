From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/24] net, diet: Make rtnetlink optional
Date: Mon, 05 May 2014 23:08:30 -0400 (EDT)
Message-ID: <20140505.230830.1291070654883866275.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-13-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-13-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon,  5 May 2014 15:26:01 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> Small systems can use ioctl/ifconfig for routing and
> interface configuration. Make rtnetlink optional
> This saves ~29k without LTO, more with LTO.
> 
>    text    data     bss     dec     hex filename
>  483545   19371   13480  516396   7e12c net/built-in.o-with-rtnetlink
>  454365   19275   12936  486576   76cb0 net/built-in.o-wo-rtnetlink
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Andi, I've had about enough with this patch series.

We have moved several tools to only use netlink because it's
the only extensible facility, and we are not looking back.

The moment one of these "small" systems, or whatever you want to call
it, tries to use any feature added to device configuration in the last
20 years ioctl doesn't cut it.
