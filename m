From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] at86rf230: fix build warning
Date: Tue, 15 Sep 2015 13:44:57 +0530
Message-ID: <20150915081457.GH9305@sudip-pc>
References: <1441964764-15611-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrew Morton <akpm@linux-foundation.org>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1441964764-15611-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 03:16:04PM +0530, Sudip Mukherjee wrote:
> e616a00ce786 ("drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL")
> has removed the usage of the integer "ret" but missed removing the
> variable. And we were getting a build warning about "unused variable".
> 
> Fixes: e616a00ce786 ("drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL")
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
Please drop this patch. This was against a temporary fix by Stephen on
linux-next. The commit is not availble now.

regards
sudip
