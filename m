From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] bridge: MAC learning uevents
Date: Thu, 8 Sep 2016 14:16:26 -0700
Message-ID: <20160908141626.0ae9025a@xeon-e3>
References: <7824e091-6b1a-bf39-0f78-1c9084d59972@herrendoerfer.name>
        <20160908083920.0d421951@xeon-e3>
        <F1E0DECE-4C8F-487A-B1CD-B3ADFD8DC1B1@herrendoerfer.name>
        <9f5db5b9-37dc-91c0-70e2-38644cc5bdb7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name>,
        netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35399 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932460AbcIHVQQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 17:16:16 -0400
Received: by mail-pf0-f180.google.com with SMTP id w87so21849265pfk.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 14:16:16 -0700 (PDT)
In-Reply-To: <9f5db5b9-37dc-91c0-70e2-38644cc5bdb7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Sep 2016 11:30:08 -0700
Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 09/08/2016 10:19 AM, D. Herrendoerfer wrote:
> > 
> > On 08 Sep 2016, at 17:39, Stephen Hemminger <stephen@networkplumber.org> wrote:
> >   
> >> On Thu, 8 Sep 2016 15:06:16 +0200
> >> "D. Herrendoerfer" <d.herrendoerfer@herrendoerfer.name> wrote:
> >>  
> >>> Hello,
> >>>
> >>> I'd like to start a discussion if it makes sense to add an optional feature
> >>>
> >>> to the bridge MAC address learning code to generate kernel uevents for  
> > 
> > [SNIP]
> >   
> >>>
> >>> I'm porting my patch (for 3.10.0) to head, and will make it available, I 
> >>> just want some
> >>>
> >>> valuable feedback as early as possible.
> >>>
> >>>
> >>> Thanks, D.Herrendoerfer  
> >>
> >> This should be possible by listening for netlink events.
> >> No need for udev interaction.  
> > 
> > No, there are none, not for changes to the bridge forwarding table, also this would 
> > require a tool to continuously listen for changes.  
> 
> Wat do you expect uevent to solve here that netlink + a monitoring
> program can't?
> 
> There is quite a bit of code in net/bridge/br_fdb.c just to deal with
> notifying learned/added MAC addresses, is not that where you should
> start adding what you are after (if that is not supported as of latest
> mainline)?

just like neighbor table modifications, it should be possible to listen for
events with netlink. Doing it through uevent is the wrong model.
