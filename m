From: Jon Hunter <jonathanh@nvidia.com>
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Mon, 14 Nov 2016 09:34:21 +0000
Message-ID: <f0d21edc-060b-bd9b-fced-faf1f51e8467@nvidia.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com>
 <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
 <00e501d23e54$337d4b70$9a77e250$@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <allan@asix.com.tw>, <robert.foss@collabora.com>,
        <freddy@asix.com.tw>, <Dean_Jenkins@mentor.com>,
        <Mark_Craske@mentor.com>, <davem@davemloft.net>,
        <ivecera@redhat.com>, <john.stultz@linaro.org>,
        <vpalatin@chromium.org>, <stephen@networkplumber.org>,
        <grundler@chromium.org>, <changchias@gmail.com>, <andrew@lunn.ch>,
        <tremyfr@gmail.com>, <colin.king@canonical.com>,
        <linux-usb@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <vpalatin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate16.nvidia.com ([216.228.121.65]:10434 "EHLO
        hqemgate16.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbcKNJfQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 04:35:16 -0500
In-Reply-To: <00e501d23e54$337d4b70$9a77e250$@asix.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Allan,

On 14/11/16 08:50, ASIX_Allan [Home] wrote:
> It seems the AX88772x dongle had been unexpectedly removed while running the
> ax88772_suspend() routine. If yes, you might see these error messages
> because the hardware had been absent.    

In my case the hardware was never removed. The boards are in a test
fixture that are not touched. This is seen on more than one board. By
reverting this change I no longer see the error messages and appears to
be 100% reproducible.

Jon

-- 
nvpublic
