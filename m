From: Dave Jones <davej@redhat.com>
Subject: Re: out of bounds writes in net/hsr/
Date: Tue, 4 Mar 2014 11:30:02 -0500
Message-ID: <20140304163002.GA32328@redhat.com>
References: <20140304032757.GA19048@redhat.com>
 <5315FA3B.8020700@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaCDREp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 12:04:45 -0500
Content-Disposition: inline
In-Reply-To: <5315FA3B.8020700@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 05:07:23PM +0100, Arvid Brodin wrote:
 > On 2014-03-04 04:27, Dave Jones wrote:
 > > I found this in coverity, and I think it's a real bug..
 > > 
 > > hsr_register_frame_in does a check that dev_idx is between 0 and 2,
 > > therefore, a dev_idx of 2 is possible when it gets to the array writes
 > > at the end of the function. 
 > 
 > Thanks for finding this; it is a bug (although I don't think it has 
 > actually lead to any out of bound accesses). 
 > 
 > However, I think you are a bit late - I believe this was fixed in a patch 
 > from Dan Carpenter just a few days ago. See
 > 
 > http://www.spinics.net/lists/netdev/msg272815.html

excellent, thanks for checking.

	Dave
