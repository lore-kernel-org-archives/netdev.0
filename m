From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 12:12:05 -0500
Message-ID: <20061213171205.GB26415@csclub.uwaterloo.ca>
References: <20061213180032.241265000.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:33919 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965042AbWLMRMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:12:07 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061213180032.241265000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 06:00:35PM +0100, Jiri Benc wrote:
> John, in addition to the previous pull request, please also apply the
> following two fixes.

What is the state of the rx2x00 driver by now?  I have been playing
around with an rt2500 based card, with some success but not enough for
me to switch over from wired ethernet yet on my machine.  I used to get
lots of hard lockups, but with the latest cvs snapshot in debian's
rt2x00-source package, it no longer seems to lockup.  It also now works
with WPA without using wpa_supplicant (Yay!  Good work.), it does
however very frequently pause the transfer, and then after a while (20
or 30 seconds probably) it will start moving data again and my transfer
will continue.  Is this considered normal for now?  My card happens to
be a linksys WMP54G version 4.0.  At least pauses beat crashes.  It's
going the right way for a work in progress.

I guess I should go read the bug tracking system and try out newer cvs
versions. :)

--
Len Sorensen
