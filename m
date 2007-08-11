From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44-ssb: Fix the SSB dependency hell
Date: Sat, 11 Aug 2007 16:42:39 +0200
Message-ID: <200708111642.39348.mb@bu3sch.de>
References: <200708110208.21624.mb@bu3sch.de> <200708111136.46781.mb@bu3sch.de> <20070811143002.GE22213@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:50917
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758300AbXHKOnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2007 10:43:51 -0400
In-Reply-To: <20070811143002.GE22213@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 11 August 2007 16:30:02 Adrian Bunk wrote:
> And offering more options than required or manually sending users into 
> other menus are bad thing for your users.

Breaking compilations are as bad.
So, does your example actually work in practice and not only
in theory, too? My select stuff should have worked in theory, too.
But it broke, for whatever reasons on whatever weird setups.

We somehow are in an endless loop here:

loop:
	implement it with select
	people complain select it bad and suggest to implement it with depends on
	implement it with depends on
	either
		users don't find it anymore
		users complain
	or
		it needs way to tell the user what to select first
		developers complain
	goto loop

;)

-- 
Greetings Michael.
