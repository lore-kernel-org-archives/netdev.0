From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable
 options
Date: Tue, 15 Nov 2016 09:03:43 -0800
Message-ID: <476b72f3-5efe-3551-6c24-0e378d655a0f@gmail.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
 <1479220154-25851-2-git-send-email-jbrunet@baylibre.com>
 <20161115163036.GB23231@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>, Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35733 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbcKORDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 12:03:46 -0500
In-Reply-To: <20161115163036.GB23231@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 08:30 AM, Andrew Lunn wrote:
> On Tue, Nov 15, 2016 at 03:29:12PM +0100, Jerome Brunet wrote:
>> On some platforms, energy efficient ethernet with rtl8211 devices is
>> causing issue, like throughput drop or broken link.
>>
>> This was reported on the OdroidC2 (DWMAC + RTL8211F). While the issue root
>> cause is not fully understood yet, disabling EEE advertisement prevent auto
>> negotiation from enabling EEE.
>>
>> This patch provides options to disable 1000T and 100TX EEE advertisement
>> individually for the realtek phys supporting this feature.
> 
> Looking at the code, i don't see anything specific to RealTek
> here. This all seems generic. So should it be in phy.c and made a
> generic OF property which can be applied to any PHY which supports
> EEE.

Agreed. Just to be sure, Jerome, you did verify that with EEE no longer
advertised, ethtool --set-eee fails, right? The point is that you may be
able to disable EEE on boot, but if there is a way to re-enable it later
on, we would want to disable that too.
-- 
Florian
