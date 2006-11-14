From: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Wed, 15 Nov 2006 01:40:40 +1100
Message-ID: <20061114144040.GA18175@keitarou>
References: <ej09qf$2nv$1@sea.gmane.org> <200611111607.05420.mb@bu3sch.de> <20061112012430.GA29648@keitarou> <200611120934.28133.mb@bu3sch.de> <20061114142959.GA17486@keitarou>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from betty.cbit.net.au ([202.55.154.10]:31710 "EHLO mail.cbit.net.au")
	by vger.kernel.org with ESMTP id S965889AbWKNOih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 09:38:37 -0500
To: netdev@vger.kernel.org, linville@tuxdriver.com,
	Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <20061114142959.GA17486@keitarou>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 15, 2006 at 01:29:59AM +1100, Paul TBBle Hampson wrote:
> Just to summarise results so far:

> (Current version)
> bcm43xx-d80211 w/v3 firmware and TKIP: Garbled broadcast RX
> bcm43xx-d80211 w/v4 firmware and TKIP: Garbled broadcast RX
> bcm43xx-d80211 w/v4 firmware and WEP-104: Correct broadcast RX

> (version from wireless-dev before October 23rd, unsure of exact date)
> bcm43xx (softmac) w/v3 firmware and TKIP: Correct broadcast RX

> Still to test: bcm43xx-d80211 w/v3 firmware and WEP-104

bcm43xx-d80211 w/v3 firmware and WEP-104: Garbled _everything_ RX
Of course, that's to be expected. WEP only uses broadcast keys, and
we knew they were failing in software mode.

-- 
-----------------------------------------------------------
Paul "TBBle" Hampson, B.Sc, LPI, MCSE
On-hiatus Asian Studies student, ANU
The Boss, Bubblesworth Pty Ltd (ABN: 51 095 284 361)
Paul.Hampson@Pobox.Com

Of course Pacman didn't influence us as kids. If it did,
we'd be running around in darkened rooms, popping pills and
listening to repetitive music.
 -- Kristian Wilson, Nintendo, Inc, 1989

License: http://creativecommons.org/licenses/by/2.1/au/
-----------------------------------------------------------
