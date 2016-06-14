From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: iwlegacy: avoid warning about missing braces
Date: Tue, 14 Jun 2016 14:26:37 +0000 (UTC)
Message-ID: <20160614142637.553336130F@smtp.codeaurora.org>
References: <1463644741-529379-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463644741-529379-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> gcc-6 warns about code in il3945_hw_txq_ctx_free() being
> somewhat ambiguous:
> 
> drivers/net/wireless/intel/iwlegacy/3945.c:1022:5: warning: suggest explicit braces to avoid ambiguous 'else' [-Wparentheses]
> 
> This adds a set of curly braces to avoid the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

2cce76c3fab4 iwlegacy: avoid warning about missing braces

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9124661/
