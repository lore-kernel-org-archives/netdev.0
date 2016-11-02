From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH (net.git) 0/3] stmmac: fix PTP support
Date: Wed, 2 Nov 2016 12:33:35 +0530
Message-ID: <CAJ3bTp4df45o5bYZXR+LcdXscty-GoO-uN9mqGFF551FzpxiBQ@mail.gmail.com>
References: <1477464964-5960-1-git-send-email-peppe.cavallaro@st.com> <20161026085812.GD11974@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        netdev <netdev@vger.kernel.org>, alexandre.torgue@st.com,
        linux-kernel@vger.kernel.org,
        Seraphin Bonnaffe <seraphin.bonnaffe@st.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37347 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbcKBHDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 03:03:37 -0400
Received: by mail-wm0-f41.google.com with SMTP id t79so16658600wmt.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 00:03:37 -0700 (PDT)
In-Reply-To: <20161026085812.GD11974@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 2:28 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Wed, Oct 26, 2016 at 08:56:01AM +0200, Giuseppe Cavallaro wrote:
>> This subset of patches aim to fix the PTP support
>> for the stmmac and especially for 4.x chip series.
>> While setting PTP on an ST box with 4.00a Ethernet
>> core, the kernel panics due to a broken settings
>> of the descriptors. The patches review the
>> register configuration, the algo used for configuring
>> the protocol, the way to get the timestamp inside
>> the RX/TX descriptors and, in the end, the statistics
>> displayed by ethtool.
>>
>> Giuseppe Cavallaro (3):
>>   stmmac: update the PTP header file
>>   stmmac: fix PTP support for GMAC4
>>   stmmac: fix PTP type ethtool stats
>
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Acked-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>



-- 
wwr
Rayagond
