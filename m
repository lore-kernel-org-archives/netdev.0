From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 19:15:52 +0100
Message-ID: <200702051915.52898.IvDoorn@gmail.com>
References: <200701312016.50524.IvDoorn@gmail.com> <200702051843.07026.mb@bu3sch.de> <20070205190834.40c0a619@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.231]:62141 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932622AbXBESQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 13:16:15 -0500
Received: by wr-out-0506.google.com with SMTP id i22so1306121wra
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 10:16:15 -0800 (PST)
In-Reply-To: <20070205190834.40c0a619@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 19:08, Jiri Benc wrote:
> On Mon, 5 Feb 2007 18:43:06 +0100, Michael Buesch wrote:
> > I also think that sending RTS in software is not going to work,
> > as the timing can not be guaranteed. And timing is why we do it in
> > the first place. If the HW is not capable of sending RTS frames, we
> > should not try to emulate them in SW, as it might make the situation
> > even worse by messing up the NAVs by wrong timing.
> 
> That's not emulation in the software, it's just similar approach as
> with sending fragmented frames - you need (more or less) precise timing
> there as well and many cards still want them enqueued one-by-one. The
> firmware takes care of the precise timing. The same could apply to RTS
> frames (i. e. the firmware recognize them and doesn't send them before
> it has the next frame ready).

And even for a "dumb" device like rt2x00 (no firmware for rt2400pci, rt2500pci or rt2500usb)
it still has rts capabilities. It is just not capable of creating the frame, but
the descriptor has a special field that should be set in case of a rts frame.
So that would suggest that the device will treat the frame a little bit
different than a regular frame.

Ivo
