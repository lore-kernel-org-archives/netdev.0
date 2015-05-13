From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] carl9170: match wait_for_completion_timeout return type
Date: Wed, 13 May 2015 16:40:41 +0200
Message-ID: <CAAd0S9D_5QrKJWcwGYHSvg3jJRpBFG1mRdHDrUOMcOM9+PXLyg@mail.gmail.com>
References: <1431454718-23701-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33334 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933442AbbEMOkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 10:40:42 -0400
In-Reply-To: <1431454718-23701-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 8:18 PM, Nicholas Mc Guire <hofrat@osadl.org> wrote:
> Return type of wait_for_completion_timeout is unsigned long not int.
> An appropriately named unsigned long is added, and the assignments
> as well as error checking fixed up.
>
> API conformance testing for completions with coccinelle spatches are being
> used to locate API usage inconsistencies:
> ./drivers/net/wireless/ath/carl9170/usb.c:675
>         int return assigned to unsigned long
>
> Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
> CONFIG_CARL9170=m
>
> Patch is against 4.1-rc3 (localversion-next is -next-20150512)
>
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
Acked-by: Christian Lamparter <chunkeey@googlemail.com>
