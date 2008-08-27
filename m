From: David Miller <davem@davemloft.net>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 16:07:10 -0700 (PDT)
Message-ID: <20080827.160710.80433973.davem@davemloft.net>
References: <20080827223410.GC26610@one.firstfloor.org>
	<20080827.153907.157997966.davem@davemloft.net>
	<87fxoqqd62.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753833AbYH0XHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:07:15 -0400
In-Reply-To: <87fxoqqd62.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Thu, 28 Aug 2008 00:57:25 +0200

> David Miller <davem@davemloft.net> writes:
> 
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Thu, 28 Aug 2008 00:34:10 +0200
> >
> >> It fixes an old performance problem at least. I'm not aware 
> >> of any new ones in this area because the code in this 
> >> function hasn't changed since I last looked.
> >
> > That's exactly what this thread is about, things got slower for
> > some reason even though nothing specifically changed in this area.
> 
> I reread the original bug and it says nothing about a regression
> (unless I'm blind). I think the reporter just ran into the slowness that
> was pretty much always there[1] (and which my patch improves)

It's a regression compared to older kernels.  It got slower by a
factor of 5 or something like that.
