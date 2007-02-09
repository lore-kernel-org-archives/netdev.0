From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 19:48:12 +0100
Message-ID: <200702091948.13296.mb@bu3sch.de>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joseph Jezak <josejx@gentoo.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Bcm43xx-dev@lists.berlios.de
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:56663
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423182AbXBISsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 13:48:18 -0500
In-Reply-To: <45CCBB93.2040703@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 19:21, Larry Finger wrote:
> Michael Buesch wrote:
> > On Friday 09 February 2007 23:22, Joseph Jezak wrote:
> >>> Well, I don't review the rest until you say to which specs you did the changes. ;)
> >> http://bcm-specs.sipsolutions.net/B5PHY
> >>
> >> Larry was working from the old specs, so when I updated it, I only 
> >> updated the old specs.  I'll fix the v4 specs soon.
> > 
> > Ah, ok. I think we should decide on which specs carry most recent information.
> > I think v3 specs should be considered obsolete and new information/ fixes
> > should go into v4. It is already too confusing where to find newest information
> > to a certain thing.
> > 
> 
> I'll agree to that as long as there is a clear indication of any differences between V3 and V4 firmware.

Well, the difference between v3 and v4 is:
* The SHM API.
* v4 may include less BPHY stuff, as broadcom's v4 drivers don't include BHY anymore.

So I'd say for everything bug BPHY the v4 specs should be considered latest.

-- 
Greetings Michael.
