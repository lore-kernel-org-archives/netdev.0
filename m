From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Traffic shaping - class ID 16bit limit?
Date: Thu, 25 Aug 2011 10:10:38 -0700
Message-ID: <20110825101038.6b8c3e02@nehalam.ftrdhcpuser.net>
References: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
	<20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
	<CAO0uZ+_6xC0gymfbu28PRK4SaVgkGaSbbe-PgXvZ4h-cPp8k2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53157 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754152Ab1HYRK2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 13:10:28 -0400
In-Reply-To: <CAO0uZ+_6xC0gymfbu28PRK4SaVgkGaSbbe-PgXvZ4h-cPp8k2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2011 19:06:58 +0200
Miroslav Kratochvil <exa.exa@gmail.com> wrote:

> >> Technically the ClassID seems to be "hardcoded" as a 16bit value, but
> >> after some source searching, I haven't found any good reason for it to
> >> be 16-bit only.
> >
> > Granted it was a poor choice in the initial design.
> > It is wired into the API and changing it would be quite painful.
> >
> 
> I was feeling something like that would come.
> 
> If I get it correctly, the API change would consist of:
> 
> - some netlink protocol change
> - slight modification of qdisc_class_hash
> - modifications in all (four?) hierarchical schedulers
> - tiny expansion of userspace tc utility

And all the magic compatiablity layers to make old code
work with new code.
