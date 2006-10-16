From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 1/5] d80211: remove bitfields from ieee80211_tx_control
Date: Mon, 16 Oct 2006 22:05:35 +0200
Message-ID: <200610162205.35649.mb@bu3sch.de>
References: <C86180A8C204554D8A3323D8F6B0A29F01851A93@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David Kimdon" <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jiri Benc" <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:13226
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750790AbWJPUGU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 16:06:20 -0400
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01851A93@dhost002-46.dex002.intermedia.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 October 2006 21:34, Simon Barber wrote:
> Removing the bitfields makes the code much harder to read and maintain.
> Here we are working around a problem with the compiler by making the
> code ugly - rather than fixing the compiler. The compilers are getting
> better and better (GCC 4 has much better handling of this type of
> optimization) but the code will remain ugly for ever.

Yeah, that's my opinion on this, too.

But I still like the  unsigned int foo:16; => u16 foo;  type of conversions.

-- 
Greetings Michael.
