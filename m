From: "Ayaz Abdulla" <AAbdulla@nvidia.com>
Subject: RE: [patch 02/10] forcedeth: power down phy when interface is down
Date: Fri, 14 Dec 2007 12:30:12 -0800
Message-ID: <F72FA20C31DD4F4C997B91C5B3690A091A990F@hqemmail07.nvidia.com>
References: <20071213170721.e71ff79f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>
To: "Andrew Morton" <akpm@linux-foundation.org>,
	"Ed Swierk" <eswierk@arastra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19643 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756522AbXLNUca convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 15:32:30 -0500
In-Reply-To: <20071213170721.e71ff79f.akpm@linux-foundation.org>
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ed,

You mention that the phy will become 100Mbit half duplex, but during
nv_close, the phy setting is not modified. This might be a separate
issue.

Ayaz

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org] 
Sent: Thursday, December 13, 2007 5:07 PM
To: Ed Swierk
Cc: Ayaz Abdulla; jeff@garzik.org; netdev@vger.kernel.org
Subject: Re: [patch 02/10] forcedeth: power down phy when interface is
down


On Thu, 13 Dec 2007 16:53:58 -0800
"Ed Swierk" <eswierk@arastra.com> wrote:

> On 12/13/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Does this patch actually fix any observeable problem?
> 
> Without the patch, ifconfig down leaves the physical link up, which
> confuses datacenter users who expect the link lights both on the NIC
> and the switch to go out when they bring an interface down.
> 
> Furthermore, even though the phy is powered on, autonegotiation stops
> working, so a normally gigabit link might suddenly become 100 Mbit
> half-duplex when the interface goes down, and become gigabit when it
> comes up again.
> 

OK, thanks, I added that text to the changelog along with Ayaz's
objection
and shall continue to bug people with it until we have a fix merged.  
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
