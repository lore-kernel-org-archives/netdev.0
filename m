From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Tue, 17 Oct 2006 10:26:55 -0700
Message-ID: <20061017172655.GB13701@devicescape.com>
References: <200610161807.25261.mb@bu3sch.de> <C86180A8C204554D8A3323D8F6B0A29F01851A93@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:49090 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1751345AbWJQR05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 13:26:57 -0400
To: Simon Barber <simon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01851A93@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I am not particularily attached to bitfields or no bitfields.  I am
interested in getting d80211 merged.  Bitfields have been discussed
as an important TODO.  Perhaps this can serve as a starting point for
discussion of the tasks to complete before d80211 is merged?

On Mon, Oct 16, 2006 at 12:34:07PM -0700, Simon Barber wrote:
> Removing the bitfields makes the code much harder to read and maintain.

I agree that we end up with more characters in the file, the bitfield
syntax is more concise.  However, I don't find it 'much' harder to
read or maintain, it is a matter of taste.

> Here we are working around a problem with the compiler by making the
> code ugly - rather than fixing the compiler. The compilers are getting
> better and better (GCC 4 has much better handling of this type of
> optimization) but the code will remain ugly for ever.

Well at least as far as code size goes gcc 4.1.2 still produces
slightly larger code with the bitfields.

-David
