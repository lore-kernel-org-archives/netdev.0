From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] uio-hv-generic: store physical addresses instead of virtual
Date: Fri, 09 Dec 2016 21:38:16 +0100
Message-ID: <3783097.3X8RYproPn@wuerfel>
References: <20161209114456.3719619-1-arnd@arndb.de> <20161209092844.75b73e8d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
        linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161209092844.75b73e8d@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, December 9, 2016 9:28:44 AM CET Stephen Hemminger wrote:
> On Fri,  9 Dec 2016 12:44:40 +0100
> Arnd Bergmann <arnd@arndb.de> wrote:

> > Fixes: 95096f2fbd10 ("uio-hv-generic: new userspace i/o driver for VMBus")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Thanks, the code was inherited from outside, and only tested on x86_64.
> Not sure which platform and GCC version generates the warning, was this just W=1?
> 
> Acked-by: Stephen Hemminger <sthemmin@microsoft.com>

This was a regular warning with a randconfig build on arm32, but
it happens on any 32-bit architecture when CONFIG_PHYS_ADDR_T_64BIT
is enabled.

	Arnd
