From: Hong Liu <hong.liu@intel.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Tue, 24 Oct 2006 16:20:53 +0800
Message-ID: <1161678053.7083.7.camel@devlinux-hong>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4943 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S965102AbWJXI1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 04:27:48 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061023145646.32bbd59f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-23 at 20:56, Jiri Benc wrote:
> On Mon, 23 Oct 2006 14:48:00 +0200, Johannes Berg wrote:
> > On Mon, 2006-10-23 at 14:40 +0200, Jiri Benc wrote:
> > > I don't like extending ieee80211_tx_control by 16 more bytes. The
> > > driver is required to store a copy of each ieee80211_tx_control
> > > (because it's copied to ieee80211_tx_status). I don't have a better
> > > idea, though. Anybody?
> > 
> > A pointer that goes somewhere else? I suppose it could even be in the
> > skb's cb field.
> 
> Yes, that could work. Thanks!
> 
> > Also, something I just came to think of, bcm43xx does phase2 mixing in
> > hw and requires phase1 in software. Do we handle that with or without
> > this patch? If not, it'd be nice to fix it up together.
> 
> It's not supported now. And it's really a good idea to extend the patch
> to support the bcm43xx case as well.
> 
>  Jiri

It's really strange bcm43xx only does phase2 mixing in hw. With all the
code that does phase2 mixing, doing phase1 mixing is very cheap.

With Jiri's ieee80211_tx_ctrl_common patch, I think we can put the
rc4key or phase1 key in ieee80211_tx_control with each TX packet.


Thanks,
Hong
