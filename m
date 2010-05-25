From: Gertjan van Wingerde <gwingerde@gmail.com>
Subject: Re: pull request: wireless-2.6 2010-05-25
Date: Tue, 25 May 2010 22:29:14 +0200
Message-ID: <4BFC331A.9030606@gmail.com>
References: <20100525170401.GE31753@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100525170401.GE31753@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John,

On 05/25/10 19:04, John W. Linville wrote:
> Dave,
> 
> Here are a number of fixes intended for 2.6.35.  Included are some
> warning fixes from Randy, some smatch-identified fixes from Dan, some
> fixes for using ath9k and IBSS mode, the removal of a PCI ID that was
> optimistically added to ath9k, and a smattering of other driver fixes.
> This also includes a revert of "ath9k: Group Key fix for VAPs" which
> was reported to cause regressions due to a mac80211 change inside it
> that snuck past us... :-(
> 
> Anyway, these are mostly small(ish) and obvious.  Please let me know
> if there are problems!
> 
> Thanks,
> 
> John
> 
> ---
> 
> The following changes since commit acfbe96a3035639619a6533e04d88ed4ef9ccb61:

<snip>
> 
> Gertjan van Wingerde (2):
>       rt2x00: Fix rt2800usb TX descriptor writing.

The patch causing the breakage this patch fixes wasn't actually upstream yet. So, 
applying this patch only is now introducing a bug in 2.6.35. I guess it is better
to revert this patch for 2.6.35.

Sorry for not being clearer about it when sending the patch to you.

---
Gertjan.
