From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 8 Sep 2016 11:30:08 -0700
Message-ID: <9f5db5b9-37dc-91c0-70e2-38644cc5bdb7@gmail.com>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
 <20160908083920.0d421951@xeon-e3>
 <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:34313 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752826AbcIHSaL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 14:30:11 -0400
Received: by mail-pa0-f67.google.com with SMTP id gi6so2707017pac.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 11:30:11 -0700 (PDT)
In-Reply-To: <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2016 10:19 AM, D. Herrendoerfer wrote:
> 
> On 08 Sep 2016, at 17:39, Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
>> On Thu, 8 Sep 2016 15:06:16 +0200
>> "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> wrote:
>>
>>> Hello,
>>>
>>> I'd like to start a discussion if it makes sense to add an optional feature
>>>
>>> to the bridge MAC address learning code to generate kernel uevents for
> 
> [SNIP]
> 
>>>
>>> I'm porting my patch (for 3.10.0) to head, and will make it available, I 
>>> just want some
>>>
>>> valuable feedback as early as possible.
>>>
>>>
>>> Thanks, D.Herrendoerfer
>>
>> This should be possible by listening for netlink events.
>> No need for udev interaction.
> 
> No, there are none, not for changes to the bridge forwarding table, also this would 
> require a tool to continuously listen for changes.

Wat do you expect uevent to solve here that netlink + a monitoring
program can't?

There is quite a bit of code in net/bridge/br_fdb.c just to deal with
notifying learned/added MAC addresses, is not that where you should
start adding what you are after (if that is not supported as of latest
mainline)?
-- 
Florian
