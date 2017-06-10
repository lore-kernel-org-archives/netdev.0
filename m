From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Add a fec_enet_clear_ethtool_stats() stub for CONFIG_M5272
Date: Sat, 10 Jun 2017 17:33:01 -0300
Message-ID: <CAOMZO5A8hv2+kr_aFQyfA=MFLGbcHwTLtdXBHhRNc_tQpDkBeA@mail.gmail.com>
References: <1497058642-31542-1-git-send-email-festevam@gmail.com> <20170610.161649.2086289606620760235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Fugang Duan <fugang.duan@nxp.com>, Andrew Lunn <andrew@lunn.ch>,
        Chris Healy <cphealy@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Paul Gortmaker <paul.gortmaker@windriver.com>,
        Fabio Estevam <fabio.estevam@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36394 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbdFJUdC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 16:33:02 -0400
Received: by mail-oi0-f68.google.com with SMTP id g14so6120238oib.3
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 13:33:02 -0700 (PDT)
In-Reply-To: <20170610.161649.2086289606620760235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 10, 2017 at 5:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Fabio Estevam <festevam@gmail.com>
> Date: Fri,  9 Jun 2017 22:37:22 -0300
>
>> From: Fabio Estevam <fabio.estevam@nxp.com>
>>
>> Commit 2b30842b23b9 ("net: fec: Clear and enable MIB counters on imx51")
>> introduced fec_enet_clear_ethtool_stats(), but missed to add a stub
>> for the CONFIG_M5272=y case, causing build failure for the
>> m5272c3_defconfig.
>>
>> Add the missing empty stub to fix the build failure.
>>
>> Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
>
> Applied, thanks.

I should have marked net-next in the Subject.

Commit 2b30842b23b9 ("net: fec: Clear and enable MIB counters on
imx51") is in net-next, so this one should go to net-next, not to net.

Sorry about that.
