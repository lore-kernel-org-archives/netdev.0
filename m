From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] ARM: dts: tango4: Request RGMII RX and TX clock delays
Date: Fri, 4 Aug 2017 13:02:57 +0200
Message-ID: <CAK8P3a2fdzrvoN5FLzmH20igc4Jxg1N1L0SmDq7idFvMeFhc_Q@mail.gmail.com>
References: <d669e207-ae47-4c9e-67c5-75424fde501f@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: arm-soc <arm@kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>, Mason <slash.tmp@free.fr>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35887 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751304AbdHDLC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 07:02:58 -0400
Received: by mail-oi0-f65.google.com with SMTP id b130so1184477oii.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 04:02:58 -0700 (PDT)
In-Reply-To: <d669e207-ae47-4c9e-67c5-75424fde501f@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 3:27 PM, Marc Gonzalez
<marc_gonzalez@sigmadesigns.com> wrote:
> RX and TX clock delays are required. Request them explicitly.
>
> Fixes: cad008b8a77e6 ("ARM: dts: tango4: Initial device trees")
> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> ---
> Arnd, Kevin, Olof, can one of you take this patch through arm-soc?

Applied to the fixes branch now.

> Greg will apply it to all stable branches, right?

He usually looks at random patches that have a 'Fixes:' line, but if you already
know that you want a bugfix to be backported, it should also come with a
'Cc: stable@vger.kernel.org' line. I've added that manually this time, but
please include it yourself if you have another patch like that.

 Thanks,

      Arnd
