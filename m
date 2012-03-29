From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: maranello for linux-current [b43 driver]
Date: Thu, 29 Mar 2012 03:29:10 -0600
Message-ID: <CAJfuBxwcRc=Fu0ZYPKGAW7buOL6muSxTYr695c3Kh32kW_Okqg@mail.gmail.com>
References: <CAJfuBxz9kVAkkSjFk2PAYLxOsgmrCx-HV0OM7EwV9J5mSzB8dA@mail.gmail.com>
 <4F74265F.8060508@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bo Han <bohan@cs.umd.edu>, netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40844 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab2C2J3l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 05:29:41 -0400
In-Reply-To: <4F74265F.8060508@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 29, 2012 at 3:07 AM, Florian Fainelli <florian@openwrt.org>=
 wrote:
> (Adding linux-wireless in CC)
>
> Le 03/29/12 00:24, Jim Cromie a =E9crit :
>>
>> you may have heard of maranello, a project to add
>> partial packet recovery to 80211, by adding block checksums
>> on transmit, validating them or re-requesting retransmit
>> of corrupted blocks.
>>
>> http://www.cs.umd.edu/projects/maranello/
>>
>> the code at the page is for 2.6.29-rc2
>>
>> Ive taken it, did some refactoring to ease merging,
>> and merged in each linux release, up to 3.3
>>

I redid it, this time no refactoring, just conflict resolution
and compile fixes.

Now pushed to:
https://github.com/jimc/linux-2.6/tree/maranello/merges

>> So I guess Im seeking advice:
>>
>> - what did I break
>> - what happens when the driver is tested

Theres a lot to fix still.
- // comments
- long lines
- unused vars
- various FIXMEs
- refactorings for better reuse in other drivers
  (this is large question, probably with lots of answers)

What drivers have FW whose source is available,
and thus hackable for maranello support ?

thanks.
Jim Cromie
