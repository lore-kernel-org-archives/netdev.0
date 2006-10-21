From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] bcm43xx: Readd dropped assignment
Date: Fri, 20 Oct 2006 23:29:00 -0400
Message-ID: <20061021032900.GB17706@redhat.com>
References: <20061017231212.A73D77B40A0@zog.reactivated.net> <200610181640.01140.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, Daniel Drake <dsd@gentoo.org>,
	Larry.Finger@lwfinger.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:13463 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S2992822AbWJUDa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 23:30:27 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200610181640.01140.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2006 at 04:40:00PM +0200, Michael Buesch wrote:
 > On Wednesday 18 October 2006 01:12, Daniel Drake wrote:
 > > Larry Finger pointed out a problem with my ieee80211 IV/ICV stripping patch,
 > > which I forgot about. Sorry about that.
 > > 
 > > The patch readds the frame_ctl assignment which was accidently dropped.
 > > 
 > > Signed-off-by: Daniel Drake <dsd@gentoo.org>
 > 
 > Whoops. Please merge this as fast as possible, John.
 > That's a real bug which prevents RX from working.

Is that one for -stable too? That file looks similar enough
between .18.1 and .19rc that it should be the case ?

	Dave

-- 
http://www.codemonkey.org.uk
