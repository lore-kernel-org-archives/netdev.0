From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFT] e100 driver on ARM
Date: Thu, 26 Apr 2007 12:09:13 -0400
Message-ID: <4630CEA9.6050100@garzik.org>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com> <20070329141041.GA3510@csclub.uwaterloo.ca> <46239138.4040408@roinet.com> <20070417173507.GB5575@csclub.uwaterloo.ca> <4630AC02.7040706@roinet.com> <20070426135013.GA12154@xi.wantstofly.org> <4630C159.1060707@garzik.org> <4630C7D0.8030901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	David Acker <dacker@roinet.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59025 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031304AbXDZQJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:09:49 -0400
In-Reply-To: <4630C7D0.8030901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Lennert Buytenhek wrote:
>>> This is all a while ago now, but wasn't the e100 S-bit patch originally
>>> written by Intel people in response to the very same quote by Russell
>>> King that you've quoted above?
>>
>> Correct.
>>
>> I just wanted to make sure it didn't kill any boxes.
> 
> Neither did we. On top of that we didn't have the equipment to test on 
> ARM on until recently, and the system that I got recently will not even 
> load the kernel with an e100 NIC in the PCI slot (way way way before 
> e100.ko loads, e1000 works just fine). that doesn't help either.
> 
> Meanwhile we've not sat still and jesse wrote a patch to have e100 use 
> IO optionally for plagued platforms which seems to fix some of these 
> issues, and Jeff Kirsher has been actively tracking a e100 IPMI issue on 
> a very specific platform.
> 
> Jeff, I think I should just push the IO patch and the sbit code to 
> Andrew and have it sit there. That is a vastly larger test resource than 
> we currently can generate for this. If needed we just let is sit there 
> for a whole release cycle before moving it to #upstream.

The sbit code has been in -mm via netdev-2.6.git#ALL for many months 
now.  I am certainly open to adding any number of "for -mm only" style 
patches that you wish to pass along, for /any/ driver: e100, e1000, ixgb.

	Jeff



