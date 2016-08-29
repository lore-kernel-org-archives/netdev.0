From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] mISDN: mark symbols static where possible
Date: Mon, 29 Aug 2016 14:15:41 +0200
Message-ID: <201608291415.41294.arnd@arndb.de>
References: <1472471973-23041-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472471973-23041-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 29 August 2016, Baoyou Xie wrote:
> We get 1 warning when biuld kernel with W=1:
> drivers/isdn/hardware/mISDN/w6692.c:851:6: warning: no previous prototype for 'initW6692' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is declared
> and don't need a declaration, but can be made static.
> so this patch marks it 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/isdn/hardware/mISDN/w6692.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

The patch looks good, but now you have sent two different patches with the same subject
line. Since this is just one driver and each instance is a trivial change, I'd suggest
doing a single combined patch for them.

Similarly, when you have multiple patches within one subsystem (e.g. two different scsi
drivers), it helps to have a series of patches as you did with the ASoC patches.

	Arnd
