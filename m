From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 18:11:25 -0400
Message-ID: <4685838D.9080108@garzik.org>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com> <20070629150350.414553d4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jason Lunz <lunz@reflexsecurity.com>,
	Mark McLoughlin <markmc@redhat.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60618 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755603AbXF2WLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 18:11:31 -0400
In-Reply-To: <20070629150350.414553d4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Fri, 29 Jun 2007 14:39:20 -0700
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> That's why we want to introduce a second e1000 driver (named differently, pick 
>> any name) that contains the new code base, side-by-side into the kernel with the 
>> current e1000.
> 
> Sounds like a reasonable approach to me (it has plenty of precedent).  But
> I forget what all the other issues were, so ignore me.

Given past history with duplicate drivers and the problems that they 
cause -- I know, I've caused some of those problems :( -- I strongly 
recommend against when it can be avoided.

Leaving e1000 with current hardware, and a new e1001 for newer hardware 
should be easier to manage for all involved, without the headaches that 
duplicate drivers cause.

An "e1001" approach also means we have a much greater chance of 
encouraging Intel down the path of clean driver-ness.

	Jeff



