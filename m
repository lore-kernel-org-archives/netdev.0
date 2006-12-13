From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 18:49:07 +0100
Message-ID: <200612131849.07265.IvDoorn@gmail.com>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2389 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbWLMRtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:49:18 -0500
Received: by nf-out-0910.google.com with SMTP id o25so582734nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 09:49:17 -0800 (PST)
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20061213171205.GB26415@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 December 2006 18:12, Lennart Sorensen wrote:
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
> however very frequently pause the transfer, and then after a while (20
> or 30 seconds probably) it will start moving data again and my transfer
> will continue.  Is this considered normal for now?  My card happens to
> be a linksys WMP54G version 4.0.  At least pauses beat crashes.  It's
> going the right way for a work in progress.
> 
> I guess I should go read the bug tracking system and try out newer cvs
> versions. :)

Well results seem to vary between users. Since recently users have started
reporting panics and freezes with rt2x00. I have not yet traced that problem
to the source, because the panics I have received don't contain any rt2x00
or d80211 functions. But the presence of the rt2x00 module is the
important factor in reproducing the crash. :(
Others however seem to have more success with rt2x00, master mode
seems to work with reasonable speed. Association with managed mode
is still very shortlifed. People who manage to get associated are being
kicked from the AP quite quickly. (This could be because d80211 is not
sending NULL-frames every once in a while).

But since results vary much between users, I can still descrive the rt2x00
state as "experimental driver"

Ivo
