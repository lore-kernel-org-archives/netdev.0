From: Jon Hunter <jonathanh@nvidia.com>
Subject: Re: [PATCH v4 3/5] net: asix: Fix AX88772x resume failures
Date: Wed, 30 Nov 2016 08:07:39 +0000
Message-ID: <b24b2fa4-88d8-5772-b79c-aa2cadd7aa1e@nvidia.com>
References: <00a601d24ab6$4e9274d0$ebb75e70$@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <allan@asix.com.tw>, <freddy@asix.com.tw>,
        <Dean_Jenkins@mentor.com>, <Mark_Craske@mentor.com>,
        <davem@davemloft.net>, <robert.foss@collabora.com>,
        <ivecera@redhat.com>, <john.stultz@linaro.org>,
        <vpalatin@chromium.org>, <stephen@networkplumber.org>,
        <grundler@chromium.org>, <changchias@gmail.com>, <andrew@lunn.ch>,
        <tremyfr@gmail.com>, <colin.king@canonical.com>,
        <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <vpalatin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate14.nvidia.com ([216.228.121.143]:10673 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753929AbcK3IHt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 03:07:49 -0500
In-Reply-To: <00a601d24ab6$4e9274d0$ebb75e70$@asix.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Allan,

On 30/11/16 03:03, ASIX_Allan [Office] wrote:
> The change fixes AX88772x resume failure by
> - Restore incorrect AX88772A PHY registers when resetting
> - Need to stop MAC operation when suspending
> - Need to restart MII when restoring PHY
> 
> Signed-off-by: Allan Chou <allan@asix.com.tw>
> Signed-off-by: Robert Foss <robert.foss@collabora.com>
> Tested-by: Robert Foss <robert.foss@collabora.com>
> Tested-by: Jon Hunter <jonathanh@nvidia.com>
> Tested-by: Allan Chou <allan@asix.com.tw>

V3 of this patch is already in the current mainline branch. So you need
to send a patch on top of V3 (or v4.9-rc7) to get this fixed. Also you
should highlight the fact that this is a fix needed for v4.9.

Cheers
Jon

-- 
nvpublic
