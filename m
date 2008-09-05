From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Fri, 5 Sep 2008 10:45:11 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0809051039070.3117@nehalem.linux-foundation.org>
References: <20080827.164649.87042354.davem@davemloft.net> <1220627292.7260.3.camel@2710p.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jouni.malinen@atheros.com
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752488AbYIERpt@vger.kernel.org>
In-Reply-To: <1220627292.7260.3.camel@2710p.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 5 Sep 2008, Alex Williamson wrote:

> On Wed, 2008-08-27 at 16:46 -0700, David Miller wrote:
> 
> > 22) Two mac80211 bug fixes from Jouni Malinen:
> >     a) Use IWEVCUSTOM so that we don't hit the 256 byte limit that
> >        IWEVASSOCREQIE has
> 
> This one breaks wireless with 32bit userspace/64bit kernel.  Bisected
> back to changeset 087d833e5a9f67ba933cb32eaf5a2279c1a5b47c:
> 
> mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM

Grr. I'd love to say "I told you so", and write another rant about -rc 
series patches. But I'm too lazy, so people - please mentally insert my 
standard rant here.

David/Jouni - just revert it?

		Linus
