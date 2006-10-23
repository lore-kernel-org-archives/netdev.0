From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Mon, 23 Oct 2006 14:56:46 +0200
Message-ID: <20061023145646.32bbd59f@griffin.suse.cz>
References: <1161335976.21402.11.camel@devlinux-hong>
	<20061023144028.629dc5d8@griffin.suse.cz>
	<1161607680.6617.36.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hong Liu <hong.liu@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:15326 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964782AbWJWM4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 08:56:48 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161607680.6617.36.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Oct 2006 14:48:00 +0200, Johannes Berg wrote:
> On Mon, 2006-10-23 at 14:40 +0200, Jiri Benc wrote:
> > I don't like extending ieee80211_tx_control by 16 more bytes. The
> > driver is required to store a copy of each ieee80211_tx_control
> > (because it's copied to ieee80211_tx_status). I don't have a better
> > idea, though. Anybody?
> 
> A pointer that goes somewhere else? I suppose it could even be in the
> skb's cb field.

Yes, that could work. Thanks!

> Also, something I just came to think of, bcm43xx does phase2 mixing in
> hw and requires phase1 in software. Do we handle that with or without
> this patch? If not, it'd be nice to fix it up together.

It's not supported now. And it's really a good idea to extend the patch
to support the bcm43xx case as well.

 Jiri

-- 
Jiri Benc
SUSE Labs
