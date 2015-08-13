From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ath9k_htc: wmi: match wait_for_completion_timeout
	return type
Date: Thu, 13 Aug 2015 12:26:54 +0000 (UTC)
Message-ID: <20150813122654.733DA14037D@smtp.codeaurora.org>
References: <1431621821-8173-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
In-Reply-To: <1431621821-8173-1-git-send-email-hofrat@osadl.org>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org


> Return type of wait_for_completion_timeout is unsigned long not int.
> As time_left is exclusively used for wait_for_completion_timeout here its
> type is simply changed to unsigned long.
> 
> API conformance testing for completions with coccinelle spatches are being
> used to locate API usage inconsistencies:
> ./drivers/net/wireless/ath/ath9k/wmi.c:331
> 	int return assigned to unsigned long
> 
> Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
> CONFIG_ATH9K_HTC=m
> 
> Patch is against 4.1-rc3 (localversion-next is -next-20150514)
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
