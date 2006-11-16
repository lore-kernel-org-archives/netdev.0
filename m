From: Paul TBBle Hampson <Paul.Hampson@Pobox.com>
Subject: Re: [PATCH, RFT]: Fix bcm43xx-d80211 hwcrypto
Date: Thu, 16 Nov 2006 23:34:49 +1100
Message-ID: <20061116123449.GA2927@keitarou>
References: <ej09qf$2nv$1@sea.gmane.org> <200611120934.28133.mb@bu3sch.de> <20061114142959.GA17486@keitarou> <200611151948.08243.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from betty.cbit.net.au ([202.55.154.10]:32202 "EHLO mail.cbit.net.au")
	by vger.kernel.org with ESMTP id S1030857AbWKPMce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 07:32:34 -0500
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200611151948.08243.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 15, 2006 at 07:48:08PM +0100, Michael Buesch wrote:
> Please test if this fixes hwcrypto.
> Note that we will require v4 firmware with this patch.
> I will remove v3 firmware support, because it's _really_
> a huge pain to support both firmware versions.
> If someone wants to have v3 support, please fork my tree.
> Or alternatively simply install v4 firmware, which is a lot
> easier. ;)

Tested fine for me with both TKIP sw encryption and WEP-104 hw
encryption, on v4 firmware.

(Without applying today's new wireless-dev patches)

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
