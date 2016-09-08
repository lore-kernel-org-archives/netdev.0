From: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 8 Sep 2016 19:19:08 +0200
Message-ID: <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name> <20160908083920.0d421951@xeon-e3>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dd20738.kasserver.com ([85.13.140.210]:38090 "EHLO
        dd20738.kasserver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965834AbcIHRTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 13:19:13 -0400
In-Reply-To: <20160908083920.0d421951@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 08 Sep 2016, at 17:39, Stephen Hemminger <stephen@networkplumber.org> wrote:

> On Thu, 8 Sep 2016 15:06:16 +0200
> "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> wrote:
> 
>> Hello,
>> 
>> I'd like to start a discussion if it makes sense to add an optional feature
>> 
>> to the bridge MAC address learning code to generate kernel uevents for

[SNIP]

>> 
>> I'm porting my patch (for 3.10.0) to head, and will make it available, I 
>> just want some
>> 
>> valuable feedback as early as possible.
>> 
>> 
>> Thanks, D.Herrendoerfer
> 
> This should be possible by listening for netlink events.
> No need for udev interaction.

No, there are none, not for changes to the bridge forwarding table, also this would 
require a tool to continuously listen for changes.

Dirk
