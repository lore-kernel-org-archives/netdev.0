From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH net-next v2 3/4] Documentation: net: phy: Add blurb about RGMII
Date: Wed, 30 Nov 2016 13:43:34 +0000
Message-ID: <yw1xzikh3wxl.fsf@unicorn.mansr.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
        <20161127184449.12351-4-f.fainelli@gmail.com>
        <583B5D3B.4040108@codeaurora.org>
        <a06d903f-5b80-4683-965f-9a6a1d5fe044@gmail.com>
        <063D6719AE5E284EB5DD2968C1650D6DB023015E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: 'Florian Fainelli' <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem\@davemloft.net" <davem@davemloft.net>,
        "andrew\@lunn.ch" <andrew@lunn.ch>,
        "sf84\@laposte.net" <sf84@laposte.net>,
        "martin.blumenstingl\@googlemail.com"
        <martin.blumenstingl@googlemail.com>,
        "alexandre.torgue\@st.com" <alexandre.torgue@st.com>,
        "peppe.cavallaro\@st.com" <peppe.cavallaro@st.com>,
        "jbrunet\@baylibre.com" <jbrunet@baylibre.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:36902 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753112AbcK3Nnj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:43:39 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB023015E@AcuExch.aculab.com>
        (David Laight's message of "Wed, 30 Nov 2016 12:32:04 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> From: Florian Fainelli
>> Sent: 27 November 2016 23:03
>> Le 27/11/2016  14:24, Timur Tabi a crit :
>> >> + * PHY device drivers in PHYLIB being reusable by nature, being able to
>> >> +   configure correctly a specified delay enables more designs with
>> >> similar delay
>> >> +   requirements to be operate correctly
>> >
>> > Ok, this one I don't know how to fix.  I'm not really sure what you're
>> > trying to say.
>> 
>> What I am trying to say is that once a PHY driver properly configures a
>> delay that you have specified, there is no reason why this is not
>> applicable to other platforms using this same PHY driver.
>
> As has been stated earlier it can depend on the track lengths on the
> board itself.
> (Although 1ns is about 1 foot - so track delays of that length are unlikely.)

There could be a delay element.

-- 
Måns Rullgård
