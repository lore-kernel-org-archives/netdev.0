From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] yam: remove redundant null check on dev
Date: Wed, 27 Mar 2013 14:31:09 -0400 (EDT)
Message-ID: <20130327.143109.1828472656521608702.davem@davemloft.net>
References: <1364408704-27359-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1364408704-27359-1-git-send-email-colin.king@canonical.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 27 Mar 2013 18:25:04 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> yam_open has a redundant null check on null,  it will
> never be called with dev == NULL. Remove this redundant check.
> This also cleans up a smatch warning:
> 
> drivers/net/hamradio/yam.c:869 yam_open() warn: variable
>   dereferenced before check 'dev' (see line 867)
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next, thanks.
