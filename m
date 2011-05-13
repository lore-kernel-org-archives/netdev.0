From: wwguy <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH 2/9] iwlwifi: Silence DEBUG_STRICT_USER_COPY_CHECKS=y
 warning
Date: Thu, 12 May 2011 17:02:36 -0700
Message-ID: <1305244956.3589.1.camel@wwguy-ubuntu>
References: <1305244212-19183-1-git-send-email-sboyd@codeaurora.org>
	 <1305244212-19183-3-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305244212-19183-3-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-05-12 at 16:50 -0700, Stephen Boyd wrote:
> Enabling DEBUG_STRICT_USER_COPY_CHECKS causes the following
> warning:
> 
> In file included from arch/x86/include/asm/uaccess.h:573,
>                  from include/net/checksum.h:25,
>                  from include/linux/skbuff.h:28,
>                  from drivers/net/wireless/iwlwifi/iwl-agn-rs.c:28:
> In function 'copy_from_user',
>     inlined from 'rs_sta_dbgfs_scale_table_write' at
>     drivers/net/wireless/iwlwifi/iwl-agn-rs.c:3099:
> arch/x86/include/asm/uaccess_64.h:65:
> warning: call to 'copy_from_user_overflow' declared with
> attribute warning: copy_from_user() buffer size is not provably
> correct
> 
> presumably due to buf_size being signed causing GCC to fail to
> see that buf_size can't become negative.
> 
> Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> ---
>  drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
Thank you

Wey
