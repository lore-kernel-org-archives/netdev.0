From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v1] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Mon, 31 Jul 2017 12:59:03 +0100
Message-ID: <yw1x60e8kebc.fsf@mansr.com>
References: <823b1540-b528-bbd7-7f99-5dc39a08868a@sigmadesigns.com>
        <yw1xk22slemx.fsf@mansr.com>
        <c1bf54ee-8634-23a1-abda-55bc3fafe2a8@sigmadesigns.com>
        <yw1xfudgl7am.fsf@mansr.com>
        <446e3a95-80c3-0742-9cb1-69a8dfc9b1ae@free.fr>
        <yw1x7eyrlc3s.fsf@mansr.com>
        <f04a0cba-6c09-e9e4-f2d1-d8b2a7e276c9@free.fr>
        <4ff343de-41c7-c309-04dc-983b5fe3e066@gmail.com>
        <a5ef2294-2adf-743b-f877-144a8f3958b4@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:55186 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750933AbdGaL7F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 07:59:05 -0400
In-Reply-To: <a5ef2294-2adf-743b-f877-144a8f3958b4@free.fr> (Mason's message
        of "Mon, 31 Jul 2017 13:49:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 29/07/2017 17:18, Florian Fainelli wrote:
>
>> On 07/29/2017 05:02 AM, Mason wrote:
>>
>>> I have identified a 100% reproducible flaw.
>>> I have proposed a work-around that brings this down to 0
>>> (tested 1000 cycles of link up / ping / link down).
>> 
>> Can you also try to get help from your HW resources to eventually help
>> you find out what is going on here?
>
> The patch I proposed /is/ based on the feedback from the HW team :-(
> "Just reset the HW block, and everything will work as expected."

Nobody is saying a reset won't recover the lockup.  The problem is that
we don't know what caused it to lock up in the first place.  How do we
know it can't happen during normal operation?  If we knew the cause, it
might also be possible to avoid the situation entirely.

-- 
Måns Rullgård
