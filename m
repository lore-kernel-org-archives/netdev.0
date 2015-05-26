From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: carl9170: match wait_for_completion_timeout return type
Date: Tue, 26 May 2015 10:53:35 +0000 (UTC)
Message-ID: <20150526105335.0AEF81416BB@smtp.codeaurora.org>
References: <1431454718-23701-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431454718-23701-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added, and the assignments
> as well as error checking fixed up.
> 
> API conformance testing for completions with coccinelle spatches are being
> used to locate API usage inconsistencies:
> ./drivers/net/wireless/ath/carl9170/usb.c:675 
> 	int return assigned to unsigned long
> 
> Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
> CONFIG_CARL9170=m
> 
> Patch is against 4.1-rc3 (localversion-next is -next-20150512)
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> Acked-by: Christian Lamparter <chunkeey@googlemail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
