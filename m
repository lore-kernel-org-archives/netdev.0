From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Tue, 17 Oct 2006 10:19:51 -0700
Message-ID: <20061017171951.GA13701@devicescape.com>
References: <20061013191910.297963000@devicescape.com> <20061013192053.GB18694@devicescape.com> <200610161807.25261.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:20161 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751342AbWJQRTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 13:19:53 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610161807.25261.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2006 at 06:07:25PM +0200, Michael Buesch wrote:
> On Friday 13 October 2006 21:20, David Kimdon wrote:
> > All one-bit bitfields have been subsumed into the new 'flags'
> > structure member and the new IEEE80211_TXCTL_* definitions.  The
> > multiple bit members were converted to u8, s8 or u16 as appropriate.

I'll answer based on take1, which I just sent to the list.

> 
> And, eh, did this increase or decrease the struct size?

structure sizes did not change.

> Does this generate better or worse code?

It generates slightly smaller code with gcc 4.1.2.

-David
