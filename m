From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH UPDATE #2] Extract chip specific code out of lasi_82596.c
Date: Mon, 02 Jul 2007 09:58:31 -0400
Message-ID: <46890487.7060004@pobox.com>
References: <20070627224622.GA13356@alpha.franken.de> <4688F2D8.6020308@pobox.com> <20070702134105.GA7403@alpha.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51655 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037AbXGBN6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 09:58:33 -0400
In-Reply-To: <20070702134105.GA7403@alpha.franken.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Bogendoerfer wrote:
> On Mon, Jul 02, 2007 at 08:43:04AM -0400, Jeff Garzik wrote:
>> applied both patches.
>>
>> Please provide an update that does at Andrew requested -- rather than 
>> #include'ing lib82596.c, you should update the Makefile for relevant 
>> drivers to look like

> I got the impression that Andrew is fine with that approach after my
> explanation. I would need additional header files for all the
> different swap macros/dma stuff, and that isn't nice either, isn't it ? 

Fair enough.


> There are other drivers doing the same as I do, which didn't get any
> objections. Is it me you have a prolem with ?

Put down the insanity and paranoia juice.  Slowly.

	Jeff


