From: Dave Jones <davej@redhat.com>
Subject: Re: [GIT] Networking
Date: Fri, 13 Jun 2014 10:44:05 -0400
Message-ID: <20140613144405.GA7122@redhat.com>
References: <20140612.121445.484288603919840829.davem@davemloft.net>
 <CA+55aFy=CThoSKAJ6J3Jt-SJDkiGzwg=5tdF7_g+vyTEoPFzMQ@mail.gmail.com>
 <1402642787.4478.5.camel@jlt4.sipsolutions.net>
 <CA+55aFw-UTwA0+dmCnqwjSEW244s0CLK4V5vuh2TmLku7A0mDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbaFMOo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2014 10:44:29 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFw-UTwA0+dmCnqwjSEW244s0CLK4V5vuh2TmLku7A0mDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 13, 2014 at 07:28:33AM -0700, Linus Torvalds wrote:
 > On Thu, Jun 12, 2014 at 11:59 PM, Johannes Berg
 > <johannes@sipsolutions.net> wrote:
 > >
 > > is to be believed, then I'm not sure why you think iwlwifi is involved
 > > though.
 > 
 > Mainly just because I don't see the issue on my desktop, and iwlwifi
 > is the only network device (apart from looback) on my laptop. And it
 > does say "hw checksum", so that made me think it's the driver.
 > 
 > But:
 > 
 > > If it's iwlwifi, then maybe that commit broke something with devices
 > > that don't support checksumming?
 > 
 > that sounds quite possible.

I see it on my router with two r8169 cards too.
That does seem to support hw csum, though only on jumbo frames maybe?


	Dave
