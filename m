From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Sat, 29 Jul 2017 13:51:42 +0100
Message-ID: <yw1xy3r7jti9.fsf@mansr.com>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
        <yw1xk22slemx.fsf@mansr.com>
        <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
        <yw1xfudgl7am.fsf@mansr.com>
        <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
        <yw1x7eyrlc3s.fsf@mansr.com>
        <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
        <yw1x379fla7r.fsf@mansr.com>
        <bfc5678a-0536-7964-0d45-8f6b104e2f1a@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:48084 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753722AbdG2Mvp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 08:51:45 -0400
In-Reply-To: <bfc5678a-0536-7964-0d45-8f6b104e2f1a@free.fr> (Mason's message
        of "Sat, 29 Jul 2017 14:44:57 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 29/07/2017 14:05, Måns Rullgård wrote:
>
>> Mason writes:
>> 
>>> I'll take this opportunity to change flow control to
>>> off by default (it breaks several 100 Mbps switches).
>> 
>> I was told to have it on by default.  This is what most other drivers
>> do too.  If you have faulty switches, that's your problem.
>
> Or maybe the fault is in the HW implementation, and
> it is the board's fault that the connection is hosed.
>
> How many switches did you test the driver on?
>
> We tested 4 switches, and DHCP failed on 3 of them.
> Disabling pause frames "fixed" that.

Do those switches work with other NICs?

> I could spend weeks testing dozens of switches, but
> I have to prioritize. Ethernet flow control is simply
> not an important feature in the market the SoC is
> intended for.

Sure, flow control is rarely needed with well behaved systems.

-- 
Måns Rullgård
