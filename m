From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH 0/2] d80211, rt2x00: fixes
Date: Wed, 13 Dec 2006 15:58:04 -0500
Message-ID: <20061213205804.GE26415@csclub.uwaterloo.ca>
References: <20061213180032.241265000.midnight@suse.cz> <20061213171205.GB26415@csclub.uwaterloo.ca> <200612131849.07265.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:46702 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770AbWLMU6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 15:58:06 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
Content-Disposition: inline
In-Reply-To: <200612131849.07265.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 06:49:07PM +0100, Ivo van Doorn wrote:
> Well results seem to vary between users. Since recently users have started
> reporting panics and freezes with rt2x00. I have not yet traced that problem
> to the source, because the panics I have received don't contain any rt2x00
> or d80211 functions. But the presence of the rt2x00 module is the
> important factor in reproducing the crash. :(
> Others however seem to have more success with rt2x00, master mode
> seems to work with reasonable speed. Association with managed mode
> is still very shortlifed. People who manage to get associated are being
> kicked from the AP quite quickly. (This could be because d80211 is not
> sending NULL-frames every once in a while).

I should do some more testing and submit a report of how it is behaving.
Anything specific worth checking if it misbehaves (so far misbehaving
seems to be pausing the network transmissions for a short period and
then resuming).

> But since results vary much between users, I can still descrive the rt2x00
> state as "experimental driver"

Well every once in a while I load a new version and see how it is.
Eventually I hope it will work perfectly, and I can move my mythtv box
into the living room with the TV using wireless, rather than sitting in
the basement next to the router machine using wired ethernet.  Running
ethernet cable through the wall when the basement is all finished just
seems like too much work.  I got an rt based card because I knew it was
being worked on.  I know someday it will simply work, which is good
enough for me.

--
Len Sorensen
