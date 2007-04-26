From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFT] e100 driver on ARM
Date: Thu, 26 Apr 2007 09:20:36 -0700
Message-ID: <4630D154.7050708@intel.com>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com> <20070329141041.GA3510@csclub.uwaterloo.ca> <46239138.4040408@roinet.com> <20070417173507.GB5575@csclub.uwaterloo.ca> <4630AC02.7040706@roinet.com> <20070426135013.GA12154@xi.wantstofly.org> <4630C159.1060707@garzik.org> <4630C7D0.8030901@intel.com> <4630CEA9.6050100@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	David Acker <dacker@roinet.com>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031340AbXDZQUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:20:39 -0400
In-Reply-To: <4630CEA9.6050100@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Jeff, I think I should just push the IO patch and the sbit code to 
>> Andrew and have it sit there. That is a vastly larger test resource than 
>> we currently can generate for this. If needed we just let is sit there 
>> for a whole release cycle before moving it to #upstream.
> 
> The sbit code has been in -mm via netdev-2.6.git#ALL for many months 
> now.  I am certainly open to adding any number of "for -mm only" style 
> patches that you wish to pass along, for /any/ driver: e100, e1000, ixgb.

I think we should then just bite the bullet and move it over to #upstream for 
2.6.22, that gives us another full release cycle to monitor it.

I'll post 2 patches in a second. the first is for upstream and allows the driver 
to run with an invalid mac address in case the user overrides the eeprom 
checksum (in which case the mac address could likely be wrong). The second one 
is the I/O mode patch and for Andrew (MM), allthough the I/O mode is disabled by 
default, so it should be safe to put in upstream as well, but I leave that up to 
you to decide.

Auke
