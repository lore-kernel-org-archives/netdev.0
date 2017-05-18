From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net1080: Mark nc_dump_ttl() as __maybe_unused
Date: Thu, 18 May 2017 10:48:08 -0400 (EDT)
Message-ID: <20170518.104808.963734375405821959.davem@davemloft.net>
References: <20170517221708.183212-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mka@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517221708.183212-1-mka@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <mka@chromium.org>
Date: Wed, 17 May 2017 15:17:08 -0700

> The function is not used, but it looks useful for debugging. Adding the
> attribute fixes the following clang warning:
> 
> drivers/net/usb/net1080.c:271:20: error: unused function
>     'nc_dump_ttl' [-Werror,-Wunused-function]
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

For this and the r8152 patch, I definitely prefer that the function is
removed.

If someone needs them, they can pull it out of the GIT history.
