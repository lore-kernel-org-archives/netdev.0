From: Jon Hunter <jonathanh@nvidia.com>
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Fri, 18 Nov 2016 15:09:43 +0000
Message-ID: <1fff2d2a-7bbe-298c-3d27-7dc44df08675@nvidia.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com>
 <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
 <00e501d23e54$337d4b70$9a77e250$@asix.com.tw>
 <f0d21edc-060b-bd9b-fced-faf1f51e8467@nvidia.com>
 <010d01d23e5b$d8993130$89cb9390$@asix.com.tw>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <010d01d23e5b$d8993130$89cb9390$@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Allan,

On 14/11/16 09:45, ASIX_Allan [Office] wrote:
> Hi Jon,
> 
> Please help to double check if the USB host controller of your Terga
> platform had been powered OFF while running the ax88772_suspend() routine or
> not? 

Sorry for the delay. Today I set up a local board to reproduce this on
and was able to recreate the same problem. The Tegra xhci driver does
not power off during suspend and simply calls xhci_suspend(). I also
checked vbus to see if it was turning off but it is not. Furthermore I
don't see a new USB device detected after the error and so I don't see
any evidence that it ever disconnects.

Cheers
Jon

-- 
nvpublic
