From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Mon, 16 Oct 2006 18:07:25 +0200
Message-ID: <200610161807.25261.mb@bu3sch.de>
References: <20061013191910.297963000@devicescape.com> <20061013192053.GB18694@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:24743
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422704AbWJPQIC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 12:08:02 -0400
To: David Kimdon <david.kimdon@devicescape.com>
In-Reply-To: <20061013192053.GB18694@devicescape.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 13 October 2006 21:20, David Kimdon wrote:
> All one-bit bitfields have been subsumed into the new 'flags'
> structure member and the new IEEE80211_TXCTL_* definitions.  The
> multiple bit members were converted to u8, s8 or u16 as appropriate.

And, eh, did this increase or decrease the struct size?
Does this generate better or worse code?

-- 
Greetings Michael.
