From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: problems with e1000 and flow control
Date: Tue, 26 Feb 2008 10:10:09 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52047FCD70@orsmsx418.amr.corp.intel.com>
References: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>
To: "Wolfgang Walter" <wolfgang.walter@studentenwerk.mhn.de>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14342 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875AbYBZSYr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 13:24:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <200802252015.49862.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Walter wrote:
> it seems that e1000 enables flow-control (rx pause frames) even if
> the switch does not advertise flow control. This seems to get a
> problem as (at least some) switches then forward pause frames
> directed to the card from other hosts. We think there are hosts which
> indeed do this in the lans of our student halls.
> 
> I think flow control should be completely disabled by default if the
> switch does not advertise it. It still can be forced with ethtool.

We agree, and our latest standalone drivers have taken this into
account, but the kernel drivers have not been updated all the way yet to
fix this issue.

Thanks for the input, 
 Jesse
