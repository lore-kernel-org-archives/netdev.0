From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2 receive ring crash
Date: Fri, 12 Feb 2010 14:49:01 -0800
Message-ID: <1266014941.9371.6.camel@HP1>
References: <4B75CD1C.7090808@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Montgomery, Bob" <bob.montgomery@hp.com>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3669 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab0BLXAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 18:00:16 -0500
In-Reply-To: <4B75CD1C.7090808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2010-02-12 at 13:50 -0800, Brian Haley wrote:
> Hi Michael,
> 
> We've been seeing some crashes in the bnx2 driver lately in the 2.6.32.x stable
> series kernels, v2.0.2 of the driver.  One of our engineers has gone through
> the dumps and found some inconsistencies in the receive ring, but we don't know
> how it happened.  I was hoping someone from Broadcom might be able to take a
> look and help point us in the right direction so we can track this down, since
> it's most likely broken upstream as well.  We'll be running tests against
> the latest net-next kernel next week.  Hopefully there is enough information
> below.

Thanks for the detailed report.  The software logic to handle the rx
rings hasn't changed much for many years and my guess is that this may
be caused by firmware.  We haven't seen this type of failure in our lab.
If you can do further debugging for us, I'd like to send you a patch to
switch back to an earlier version of the firmware to see if it fixes the
issue.  Thanks again.


