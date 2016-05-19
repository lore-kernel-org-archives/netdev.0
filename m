From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwlegacy: avoid warning about missing braces
Date: Thu, 19 May 2016 14:38:57 +0200
Message-ID: <20160519123856.GA23657@redhat.com>
References: <1463644741-529379-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1463644741-529379-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2016 at 09:58:49AM +0200, Arnd Bergmann wrote:
> gcc-6 warns about code in il3945_hw_txq_ctx_free() being
> somewhat ambiguous:
> 
> drivers/net/wireless/intel/iwlegacy/3945.c:1022:5: warning: suggest explicit braces to avoid ambiguous 'else' [-Wparentheses]
> 
> This adds a set of curly braces to avoid the warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
