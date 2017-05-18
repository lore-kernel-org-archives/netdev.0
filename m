From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] net1080: Mark nc_dump_ttl() as __maybe_unused
Date: Thu, 18 May 2017 09:44:29 -0700
Message-ID: <20170518164429.GH141096@google.com>
References: <20170517221708.183212-1-mka@chromium.org>
 <20170518.104808.963734375405821959.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170518.104808.963734375405821959.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

El Thu, May 18, 2017 at 10:48:08AM -0400 David Miller ha dit:

> From: Matthias Kaehlcke <mka@chromium.org>
> Date: Wed, 17 May 2017 15:17:08 -0700
> 
> > The function is not used, but it looks useful for debugging. Adding the
> > attribute fixes the following clang warning:
> > 
> > drivers/net/usb/net1080.c:271:20: error: unused function
> >     'nc_dump_ttl' [-Werror,-Wunused-function]
> > 
> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> 
> For this and the r8152 patch, I definitely prefer that the function is
> removed.
> 
> If someone needs them, they can pull it out of the GIT history.

Thanks for you comments, I'll send out updated patches soon.
