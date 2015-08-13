From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ath9k: match wait_for_completion_timeout return type
Date: Thu, 13 Aug 2015 12:27:30 +0000 (UTC)
Message-ID: <20150813122730.D34061403CD@smtp.codeaurora.org>
References: <1431622576-9183-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431622576-9183-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Return type of wait_for_completion_timeout is unsigned long not int.
> As time_left is exclusively used for wait_for_completion_timeout here its
> type is simply changed to unsigned long.
> 
> API conformance testing for completions with coccinelle spatches are being
> used to locate API usage inconsistencies:
> ./drivers/net/wireless/ath/ath9k/link.c:197
>         int return assigned to unsigned long
> 
> Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
> 
> Patch is against 4.1-rc3 (localversion-next is -next-20150514)
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
