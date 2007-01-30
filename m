From: Dan Williams <dcbw@redhat.com>
Subject: Re: Hidden SSID's
Date: Mon, 29 Jan 2007 22:36:48 -0500
Message-ID: <1170128208.3448.6.camel@localhost.localdomain>
References: <45BACB71.2080107@lwfinger.net>
	 <1169899689.25670.3.camel@localhost.localdomain>
	 <1170019717.30318.0.camel@johannes.berg>
	 <1170075611.2895.2.camel@localhost.localdomain>
	 <20070130030911.GA6637@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932579AbXA3DeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 22:34:19 -0500
In-Reply-To: <20070130030911.GA6637@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-29 at 19:09 -0800, Jouni Malinen wrote:
> On Mon, Jan 29, 2007 at 08:00:11AM -0500, Dan Williams wrote:
> 
> > Well, there's no way a userspace program could depend on all hidden SSID
> > APs having the <hidden> tag, since if you stick in another,
> > non-ieee80211-stack card it won't be like that.  So I don't think we
> > should care about <hidden> in d80211, but I don't think we can remove it
> > from ieee80211 either.
> 
> Use of '<hidden>' is just not acceptable. IMHO, it should be removed
> from everywhere, including net/ieee80211. The sooner this is done, the
> better.

You're probably right.  Lets just pull it out of ieee80211 and be done.

dan



