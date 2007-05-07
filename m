From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] WAN Kconfig: change "depends on HDLC" to "select"
Date: Mon, 07 May 2007 09:21:18 -0400
Message-ID: <463F27CE.2040008@garzik.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3y7k1biov.fsf@maximus.localdomain> <Pine.LNX.4.64.0705070343330.2733@scrub.home> <m3tzupc6wz.fsf@maximus.localdomain> <Pine.LNX.4.64.0705071318150.1479@scrub.home> <m3r6psc0ee.fsf@maximus.localdomain> <Pine.LNX.4.64.0705071509290.1479@scrub.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Russell King <rmk@arm.linux.org.uk>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Roman Zippel <zippel@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45258 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933814AbXEGNVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 09:21:25 -0400
In-Reply-To: <Pine.LNX.4.64.0705071509290.1479@scrub.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roman Zippel wrote:
> Hi,
> 
> On Mon, 7 May 2007, Krzysztof Halasa wrote:
> 
>> Actually I can't see any bad idea here.
>> The original dependency was certainly, uhm, not the best one.
> 
> select seriously screws with the dependencies, it's especially problematic 
> if the selected symbol has other dependencies as HDLC in this case, it 
> makes it only more complicated to get the dependencies correct again.
> Please use it only if it solves a real problem.

What he's doing is the standard way to deal with library-style code. 
Nothing wrong with the patch, it's continuing established methods.

	Jeff



