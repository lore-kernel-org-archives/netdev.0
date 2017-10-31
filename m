From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: hso: remove redundant unused variable dev
Date: Tue, 31 Oct 2017 14:22:44 +0100
Message-ID: <20171031132244.GP7223@localhost>
References: <20171031120147.22348-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Johan Hovold <johan@kernel.org>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171031120147.22348-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 12:01:47PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The pointer dev is being assigned but is never used, hence it is
> redundant and can be removed. Cleans up clang warning:
> 
> drivers/net/usb/hso.c:2280:2: warning: Value stored to 'dev' is
> never read

You could also have mentioned that it was a leftover since commit
4134069f3ea6 ("hso: Use static attribute groups for sysfs entry").

> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Johan Hovold <johan@kernel.org>

Thanks,
Johan
