From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] net: wireless: move regulatory timeout work to
 power efficient workqueue
Date: Fri, 31 Jan 2014 14:38:57 +0100
Message-ID: <1391175537.4141.9.camel@jlt4.sipsolutions.net>
References: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
	 (sfid-20140131_000951_185024_42790CBB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Zoran Markovic <zoran.markovic@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org> (sfid-20140131_000951_185024_42790CBB)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-01-30 at 15:08 -0800, Zoran Markovic wrote:
> From: Shaibal Dutta <shaibal.dutta@broadcom.com>
> 
> For better use of CPU idle time, allow the scheduler to select the CPU
> on which the timeout work of regulatory settings would be executed.
> This extends CPU idle residency time and saves power.
> 
> This functionality is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

Applied.

johannes
