From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RFC][PATCH 0/2] net: support for TX timestamps
Date: Wed, 30 Jul 2008 16:02:08 +0300
Message-ID: <200807301602.09298.opurdila@ixiacom.com>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com> <200807301147.09643.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:5432 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751214AbYG3NEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 09:04:41 -0400
In-Reply-To: <200807301147.09643.netdev@axxeo.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 July 2008, Ingo Oeser wrote:

> > This patches adds TX timestamping support and is main use case is the
> > Precision Time Protocol (IEEE 1588). Both software and hardware
> > timestamping can be used.
>
> Could you please include an example on how to use
> this in userspace?
>
> A proper place for this would be Documentation/net/
>
> At the moment I cannot imagine how to use this and how
> to correlate the sent packet with the timestamp.
>
> That would also be a way to test your implementation and
> test any changes done later to it. This will avoid future bitrot.
>

Yes, of course. 

I am also planning to add mac/network/transport layer pointers in the 
sock_extended_err, so that the application can easily "navigate"  the packet 
in the error queue and map it to the sent packet. 

Thanks for the input!

tavi
