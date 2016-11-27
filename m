From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about
 RGMII
Date: Sun, 27 Nov 2016 15:02:31 -0800
Message-ID: <a06d903f-5b80-4683-965f-9a6a1d5fe044@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-4-f.fainelli@gmail.com>
 <583B5D3B.4040108@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch, sf84@laposte.net,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        jbrunet@baylibre.com
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34644 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752653AbcK0XCy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 18:02:54 -0500
Received: by mail-oi0-f65.google.com with SMTP id m75so11371291oig.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 15:02:34 -0800 (PST)
In-Reply-To: <583B5D3B.4040108@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/11/2016 à 14:24, Timur Tabi a écrit :
>> + * PHY device drivers in PHYLIB being reusable by nature, being able to
>> +   configure correctly a specified delay enables more designs with
>> similar delay
>> +   requirements to be operate correctly
> 
> Ok, this one I don't know how to fix.  I'm not really sure what you're
> trying to say.

What I am trying to say is that once a PHY driver properly configures a
delay that you have specified, there is no reason why this is not
applicable to other platforms using this same PHY driver.

>> +
>> +Common problems with RGMII delay mismatch
>> +
>> + When there is a RGMII delay mismatch between the Ethernet MAC and
>> the PHY, this
>> + will most likely result in the clock and data line sampling to
>> capture unstable
> 
> I'm not sure what "sampling to capture unstable" is supposed to mean.

When the PHY devices takes a "snapshot" of the state of the data lines,
after a clock edge, if the delay is improperly configured, these data
lines are going to still be floating, or show some kind of
capacitance/inductance effect, so the logical level which is going to be
read may be incorrect.
-- 
Florian
