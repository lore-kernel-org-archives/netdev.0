From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 12:38:43 -0500
Message-ID: <1166031523.4741.0.camel@localhost.localdomain>
References: <20061213180032.241265000.midnight@suse.cz>
	 <20061213171205.GB26415@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932574AbWLMRuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 12:50:22 -0500
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20061213171205.GB26415@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 12:12 -0500, Lennart Sorensen wrote:
> On Wed, Dec 13, 2006 at 06:00:35PM +0100, Jiri Benc wrote:
> > John, in addition to the previous pull request, please also apply the
> > following two fixes.
> 
> What is the state of the rx2x00 driver by now?  I have been playing
> around with an rt2500 based card, with some success but not enough for
> me to switch over from wired ethernet yet on my machine.  I used to get
> lots of hard lockups, but with the latest cvs snapshot in debian's
> rt2x00-source package, it no longer seems to lockup.  It also now works
> with WPA without using wpa_supplicant (Yay!  Good work.), it does

How, by private ioctls?  That's just wrong; I believe you still need to
go through the 4-way handshake to get the right keying information even
if you use PSK, which means you still need the supplicant, right?

dan

> however very frequently pause the transfer, and then after a while (20
> or 30 seconds probably) it will start moving data again and my transfer
> will continue.  Is this considered normal for now?  My card happens to
> be a linksys WMP54G version 4.0.  At least pauses beat crashes.  It's
> going the right way for a work in progress.
> 
> I guess I should go read the bug tracking system and try out newer cvs
> versions. :)
> 
> --
> Len Sorensen
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

