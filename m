From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Mon, 01 Dec 2008 17:31:26 +0100
Message-ID: <1228149086.16263.626.camel@ecld0pohly>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
	 <200811271602.16128.opurdila@ixiacom.com>
	 <1227799867.16263.517.camel@ecld0pohly>
	 <200811272053.10009.opurdila@ixiacom.com>
	 <1228127861.16263.590.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62628 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYLAQbb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 11:31:31 -0500
In-Reply-To: <1228127861.16263.590.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-01 at 10:37 +0000, Patrick Ohly wrote:
> Oliver suggested:
> > What about just creating a new pointer in the struct skbuff that points 
> > to a struct hwstamp when it is available OR the pointer is NULL when no 
> > hwstamps are available.
[...]
> So it seems to me that we need the additional 32 bit offset (or pointer,
> on 32 bit architectures) in skb which points towards the struct
> hwtstamp. But that's actually less than the additional 64 bit which hold
> the time stamp value, as in the current patch.

It doesn't even need a 32 bit offset. If it is always at the same
location in the buffer (e.g., directly after skb_shared_info), then a
single bit is sufficient. The same mechanism could be used to also store
other optional structs/fields.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

