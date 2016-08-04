From: Pavel Machek <pavel@ucw.cz>
Subject: bufferbloat on Nokia N900 (and probably anything with GPRS?)
Date: Thu, 4 Aug 2016 20:52:25 +0200
Message-ID: <20160804185225.GA12637@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pali.rohar@gmail.com, sre@kernel.org,
	kernel list <linux-kernel@vger.kernel.org>,
	aaro.koskinen@iki.fi, ivo.g.dimitrov.75@gmail.com,
	patrikbachan@gmail.com, serge@hallyn.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

GPRS/UMTS modem on N900 seems to have rather severe bufferbloat
problem -- after area of bad signal is encountered, pings are in 200
_seconds_ range.

I guess it would be good to reduce the queues, and probably drop
packets when signal is too low.

Any ideas how to make GPRS more usable?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
