From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/7][RFC] qlge: New Qlogic 10Gb Ethernet Driver.
Date: Fri, 29 Aug 2008 14:06:10 -0700
Message-ID: <20080829210610.GA14654@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8807 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbYH2VGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 17:06:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

The following patches are for further RFC for the Qlogic 10Gb driver.

This series does some cleanup as outlined below but does not yet have the
recieve buffer alignment copy per Dave Miller. That will be in the next
submittal which should be next week.
Most of the changes are per Ben Hutchings review and checkpatch.

1)  Remove ethtool code that was commented out.
2)  Change QPRINTK to use dev_printk and placed in do-while(0).
3)  Remove inclusion of linux/version.h
4)  Fixed places where variable assignments in if conditions took place.
5)  Major cleanup of header file:
	 -Added packed directive to hw structures.
	 -Moved defined constants to top of file.
6)  Added fixed timeouts for event waiting.
7)  Cleaned up receive buffer queue initialization.
8)  Fix doorbell page size to 4096. (Remove PAGE_SHIFT specifics.)
9)  Cleanup per Lindent.
10) Cleanup per checkpatch.pl
11) Change driver version to v1.00.00-b2.


Regards,
Ron Mercer
Qlogic Corporation

