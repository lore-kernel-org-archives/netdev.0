From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: [PATCH 1/4] mac80211: mesh: flush stations before beacons are
 stopped
Date: Wed, 13 Jul 2016 19:54:51 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391FCAE3@DFRE01.ent.ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <1467184459.2461.1.camel@sipsolutions.net>
 <AE1C82FB3D0EC64DB1F752C81CBD1101391FC38C@DFRE01.ent.ti.com>
 <20160713133338.GD7819@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hahn, Maital" <maitalm@ti.com>
To: Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56022 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbcGMTzR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 15:55:17 -0400
In-Reply-To: <20160713133338.GD7819@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 16:33:38, Bob Copeland wrote:
> linux- wireless@vger.kernel.org; netdev@vger.kernel.org; Hahn, Maital
> Subject: Re: [PATCH 1/4] mac80211: mesh: flush stations before beacons 
> are stopped
> 
> On Wed, Jul 13, 2016 at 10:11:25AM +0000, Machani, Yaniv wrote:
> > > > Some drivers (e.g. wl18xx) expect that the last stage in the 
> > > > de-initialization process will be stopping the beacons, similar to ap.
> > > > Update ieee80211_stop_mesh() flow accordingly.
> > > >
> > > How well have you tested that with other drivers?
> > >
> >
> > Sorry for the delayed response (I've been out) and thanks for your 
> > comments, I have tested it with RT3572 as well, and didn't see any issue.
> > I'll update the comment to reflect that.
> 
> I'll give this a test on ath10k and wcn36xx as they are the ones most 
> likely to care about ordering.
> 

Thank you,
Yaniv
> --
> Bob Copeland %% http://bobcopeland.com/
