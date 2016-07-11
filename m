From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnxt_en: initialize rc to zero to avoid returning
 garbage
Date: Mon, 11 Jul 2016 12:42:14 -0700 (PDT)
Message-ID: <20160711.124214.382443789835373290.davem@davemloft.net>
References: <1467992568-1990-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob.swindell@broadcom.com, sbaddipa@broadcom.com,
	ajit.khaparde@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467992568-1990-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  8 Jul 2016 16:42:48 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> rc is not initialized so it can contain garbage if it is not
> set by the call to bnxt_read_sfp_module_eeprom_info. Ensure
> garbage is not returned by initializing rc to 0.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
