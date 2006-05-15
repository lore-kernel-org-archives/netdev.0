From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate =?iso-8859-1?q?against=09802=2E11b?= drivers
Date: Mon, 15 May 2006 16:01:48 +0200
Message-ID: <200605151601.49290.mb@bu3sch.de>
References: <200605042232.35446.flamingice@sourmilk.net> <1147694684.29795.30.camel@johannes.berg> <20060515153533.11491649@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:64697
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S964922AbWEOOCN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 10:02:13 -0400
To: Jiri Benc <jbenc@suse.cz>, Michael Wu <flamingice@sourmilk.net>,
	netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060515153533.11491649@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 May 2006 15:35, you wrote:
> [removed some people from Cc: list as this is probably not much
> interesting for them]
>
> On Mon, 15 May 2006 14:04:44 +0200, Johannes Berg wrote:
> > On Mon, 2006-05-15 at 13:37 +0200, Jiri Benc wrote:
> > > bcm43xx does that. If I understand it correctly, bcm43xx driver doesn't
> > > know allowed modes until it loads firmware. And the firmware is not
> > > loaded until the device is opened (they probably have a reason for
> > > this).
> >
> > No, that's not right, the firmware has nothing to do with it. At least
> > not that we know of, so we treat it as all doing the same :)
>
> Hm, so your calls to ieee80211_update_hw are probably unnecessary.

No, We must allocate the ieee80211_hw, before we can attach the board.
But before we attached the board, we don't know what hardware it is.
Sure, this can be worked around by some very ugly hack (It was done
in an early version of the dscape port, because there was no 
ieee80211_update_hw), but I am not very happy to add the hack again.
(I am not sure anymore _what_ we actually did to workaround it. I would
have to look up the SVN repository ;) )
