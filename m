From: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 8 Sep 2016 19:23:49 +0200
Message-ID: <3E731737-A295-40AD-9F87-1E1A835DEADB@herrendoerfer.name>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name> <87d1ketoc2.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dd20738.kasserver.com ([85.13.140.210]:38292 "EHLO
        dd20738.kasserver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbcIHRXw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 13:23:52 -0400
In-Reply-To: <87d1ketoc2.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a reference to the virtual port in the event so you can actually
keep only one record MAC per port, I suppose the the impact would be
the same if you do this to a macvtap device on top of an ethernet device.
But granted - you could really load down the host.

Dirk

On 08 Sep 2016, at 17:15, Andi Kleen <andi@firstfloor.org> wrote:

> "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> writes:
>> 
>> I may be missing something here - I'm pretty sure there I am, but is
>> there any conceptual
>> 
>> reason why this should not be done this way ?
> 
> What happens if someone floods the network with random mac addresses?
> Sounds like an easy way to do a DoS attack against your host?
> 
> -Andi
