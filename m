From: Michael Buesch <mb@bu3sch.de>
Subject: Re: d80211-drivers pull request (week-48)
Date: Tue, 12 Dec 2006 10:35:07 +0100
Message-ID: <200612121035.07382.mb@bu3sch.de>
References: <200612110101.58710.flamingice@sourmilk.net> <457E00D4.7010201@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44945
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbWLLJfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 04:35:39 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <457E00D4.7010201@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 12 December 2006 02:07, Daniel Drake wrote:
> Michael Wu wrote:
> >       zd1211rw-d80211: Use ieee80211_tx_status
> 
> I've thought some more about this and I'm not so sure that this is the 
> right approach.
> 
> Can't devicescape be taught that the ZD1211 handles retries in hardware 
> and the stack doesn't need to worry about it?
> 
> What does devicescape do in response to not getting an ack?

It does ratecontrol based on that.
Basically: No ACK == failed packet. If too many failures,
lower the rate.

-- 
Greetings Michael.
