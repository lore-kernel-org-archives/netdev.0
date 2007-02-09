From: Larry Finger <larry.finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 09 Feb 2007 13:26:25 -0600
Message-ID: <45CCCAE1.9080901@lwfinger.net>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091811.40683.mb@bu3sch.de> <45CCF432.2070002@gentoo.org> <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCC5DF.8010001-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe,

Joseph Jezak wrote:

> That's also part of the problem.  With the v4 driver, Broadcom dropped
> support for a number of older BPHY devices (4301/4303 and some 4306
> revisions).  Do we still want to support those?  Should I continue
> writing the specs for the uCode revision it's based on or should I
> combine them?

As my 4306 is a rev 1 and is likely a version dropped in the V4 driver, I have a special interest in
this question.

My plan is to continue to maintain bcm43xx-SoftMAC for at least the BPHY and 4306 revisions even
after d80211 becomes the in-kernel driver. Of course, I hope that we will have found the killer bugs
by that time, and that maintenance will only require following kernel API changes.

As the work will be yours, you should decide if you would rather maintain the V3 and V4 pages
separately, or denote the special requirements of each firmware flavor in a combined set of pages.

Larry
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
