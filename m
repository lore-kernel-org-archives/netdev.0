From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: Remove unused array 'iwlagn_loose_lookup'
Date: Mon, 06 Jun 2016 10:54:59 +0300
Message-ID: <1465199699.1921.18.camel@coelho.fi>
References: <1464989959-2021-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxwifi@intel.com, Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464989959-2021-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-06-03 at 14:39 -0700, Guenter Roeck wrote:
> gcc-6 reports the following error if -Werror=unused-const-variable
> is enabled.
> 
> drivers/net/wireless/intel/iwlwifi/dvm/lib.c:210:21: error:
> 	'iwlagn_loose_lookup' defined but not used
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---

Thanks! I'm queuing this via our internal trees (adding "dvm: " to the
subject, to indicate this is related to the dvm module).
