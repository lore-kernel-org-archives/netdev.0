From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: use kmemdup
Date: Tue, 14 Jun 2016 14:27:09 +0000 (UTC)
Message-ID: <20160614142709.29C84613EB@smtp.codeaurora.org>
References: <1463666357-16719-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Muhammad Falak R Wani <falakreyaz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:60071 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbcFNO1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 10:27:14 -0400
In-Reply-To: <1463666357-16719-1-git-send-email-falakreyaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Muhammad Falak R Wani <falakreyaz@gmail.com> wrote:
> Use kmemdup when some other buffer is immediately copied into allocated
> region. It replaces call to allocation followed by memcpy, by a single
> call to kmemdup.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

d464fd8b48f3 brcmfmac: use kmemdup

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9127677/
