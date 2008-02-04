From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] xircom_cb should return NETDEV_TX_BUSY when there are
 no descriptors available
Date: Mon, 04 Feb 2008 17:31:50 -0500
Message-ID: <47A79256.2040805@pobox.com>
References: <20080204175653.GC16952@gateway.home> <20080204212037.GB11417@gateway.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	jamal <hadi@cyberus.ca>
To: Erik Mouw <mouw@nl.linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53987 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772AbYBDWbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 17:31:55 -0500
In-Reply-To: <20080204212037.GB11417@gateway.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Mouw wrote:
> On Mon, Feb 04, 2008 at 06:56:54PM +0100, Erik Mouw wrote:
>> Changes in other networking paths uncovered a bug in the xircom_cb
>> driver which made the kernel spew lots of the following error messages:
>>
>>   BUG eth1 code -5 qlen 0
>>
>> It turned out that the driver returned -EIO when there was no
>> descriptor available for sending packets. It should return
>> NETDEV_TX_BUSY instead. This was discussed on the netdev list before,
>> see http://thread.gmane.org/gmane.linux.network/84603 .
>>
>> Signed-off-by: Erik Mouw <mouw@nl.linux.org>
> 
> Forgot to tell: the patch is against 2.6.24 but should apply cleanly to
> the latest git kernel. The xircom_cb driver appears to be orphaned so
> I've send the patch to you.

Yep, that's the right thing to do...

	Jeff



