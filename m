From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [patch 07/30] bcm43xx: Drain TX status before starting IRQs
Date: Sat, 18 Nov 2006 20:11:27 -0800
Message-ID: <20061119041127.GU1397@sequoia.sous-sol.org>
References: <20061116024332.124753000@sous-sol.org> <20061116024511.458086000@sous-sol.org> <455F59BB.6060204@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	stable@kernel.org, Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	mb@bu3sch.de, greg@kroah.com,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:64208 "EHLO
	sous-sol.org") by vger.kernel.org with ESMTP id S1755987AbWKSELn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 23:11:43 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <455F59BB.6060204@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Larry Finger (Larry.Finger@lwfinger.net) wrote:
> The regression turns out to be a locking problem involving bcm43xx, 
> wpa_supplicant, and NetworkManager. The exact cause is unknown; however, 
> this patch is clearly not the problem. Please reinstate it for inclusion in 
> -stable.

Thanks for the follow-up, Larry.  It's queued for next -stable.

thanks,
-chris
