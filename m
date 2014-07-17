From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next v9 2/9] net: nl80211 - make
 rdev_add_virtual_intf take name_assign_type
Date: Thu, 17 Jul 2014 11:23:06 +0200
Message-ID: <1405588986.20120.1.camel@jlt4.sipsolutions.net>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
	 <1405584370-30054-3-git-send-email-teg@jklm.no>
	 <1405587855.20120.0.camel@jlt4.sipsolutions.net>
	 <CAG-2HqWGVqNFJGeh_Uj2pbC-+m8tsHeeO=f_3MD8JMcTDvpDDw@mail.gmail.com>
	 (sfid-20140717_111719_497030_C610CFFC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	John Linville <linville@tuxdriver.com>
To: Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53127 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755420AbaGQJXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 05:23:18 -0400
In-Reply-To: <CAG-2HqWGVqNFJGeh_Uj2pbC-+m8tsHeeO=f_3MD8JMcTDvpDDw@mail.gmail.com> (sfid-20140717_111719_497030_C610CFFC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 11:16 +0200, Tom Gundersen wrote:

> >>  static struct wireless_dev *ath6kl_cfg80211_add_iface(struct wiphy *wiphy,
> >>                                                     const char *name,
> >> +                                                   unsigned char name_assign_type,
> >
> > unsigned char for an enum is really odd.
> 
> Hm, this was based on the addr_assign_type attribute, which also is an
> unsigned char (and serves a very similar purpose).
> 
> Out of interest, what would you have preferred (and why)?

Even if it eventually ends up being assigned to a u8 or something, it
seems passing it around as an enum makes the interfaces better?

johannes
