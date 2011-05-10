From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] linux-firmware: bnx2: Update firmware and version
Date: Tue, 10 May 2011 16:19:16 -0700
Message-ID: <1305069556.9029.133.camel@nseg_linux_HP1.broadcom.com>
References: <1305065779-26976-1-git-send-email-mchan@broadcom.com>
 <1305069055.30435.99.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Woodhouse" <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4865 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765Ab1EJXZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2011 19:25:22 -0400
In-Reply-To: <1305069055.30435.99.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-05-10 at 16:10 -0700, David Woodhouse wrote:
> On Tue, 2011-05-10 at 15:16 -0700, Michael Chan wrote:
> > upstream kernel commit dc187cb381f1bceb30498861ece510245c43ed9f
> 
> This stuff should no longer get changed in the upstream kernel; what's
> there is *historical* and due for deletion.

OK, no more from now on.

> 
> > Update 5709 mips firmware to 6.2.1a to fix iSCSI performance
> > regression.  There was an unnecessary context read in the fast path
> > affecting performance. 
> 
> Is this update not ABI compatible? You have changed the soname of the
> firmware... was that intentional?
> 

The firmware is tightly coupled to the driver.  We only test one
combination of driver/firmware and don't guarantee compatibility with
other combinations.


