From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5] qla3xxx:resubmit support for Qlogic 4032 and fixes.
Date: Tue, 26 Dec 2006 16:34:27 -0500
Message-ID: <45919563.9030304@garzik.org>
References: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41492 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932810AbWLZVe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:34:29 -0500
To: ron.mercer@qlogic.com
In-Reply-To: <20061219181855.GA8179@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> These 5 patches were submitted on Dec 5th (1&2) and Dec 11th (3-5).  They add/fix the following
> 
> 1. Add support for Qlogic 4032 chip.
> 2. Change minor version for 4032 support.
> 3. Add delay when accessing NVRAM.
> 4. Remove NETIF_F_LLTX flag from features.  It was left over from the early driver and shouldn't be there.
> 5. Fix rx checksum warning.
> 
> We didn't get any feedback on any of these previously posted patches and couldn't find a tree where they were added.  We've build and tested them on 2.6.20-rc1.
> 
> These patches must be applied in order.

Please:

1) Fix your Mail-Followup-To header, so that it doesn't cause CC's to be 
trimmed.

2) Re-order the patches so that bug fixes come first.  Otherwise this 
entire patchset must go into netdev-2.6.git#upstream, because patch #1 
is not a bug fix and we are in a bug-fixes-only cycle.

3) Regarding patch #3:  have you verified that a missing PCI flush was 
not the cause of your problems?  It seems like udelay(1) could be removed?

ACK the other stuff

	Jeff



