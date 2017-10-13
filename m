From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] net: support bgmac with B50212E B1 PHY
Date: Fri, 13 Oct 2017 12:14:39 -0700
Message-ID: <cf1018f4-f2fb-c3fe-d76a-b968c50e9eca@gmail.com>
References: <20171012082126.30660-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>, Hauke Mehrtens <hauke@hauke-m.de>,
        Jon Mason <jon.mason@broadcom.com>,
        Steve Lin <steven.lin1@broadcom.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:44204 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJMTOn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 15:14:43 -0400
Received: by mail-qk0-f180.google.com with SMTP id r64so6226264qkc.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 12:14:43 -0700 (PDT)
In-Reply-To: <20171012082126.30660-1-zajec5@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2017 01:21 AM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> I got a report that a board with BCM47189 SoC and B50212E B1 PHY doesn't
> work well some devices as there is massive ping loss. After analyzing
> PHY state it has appeared that is runs in slave mode and doesn't auto
> switch to master properly when needed.
> 
> This patchset fixes this by:
> 1) Adding new flag support to the PHY driver for setting master mode
> 2) Modifying bgmac to request master mode for reported hardware

Sorry for the late reply, and it's been applied already, but this looks
good to me, thanks for implementing it this way!
-- 
Florian
