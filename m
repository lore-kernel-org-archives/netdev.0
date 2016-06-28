From: "Machani, Yaniv" <yanivma@ti.com>
Subject: RE: [PATCH 4/4] mac80211: sta_info: max_peers reached falsely
Date: Tue, 28 Jun 2016 13:05:18 +0000
Message-ID: <AE1C82FB3D0EC64DB1F752C81CBD1101391D5053@DFRE01.ent.ti.com>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
 <20160628111307.8784-4-yanivma@ti.com>
 <20160628111307.8784-5-yanivma@ti.com> <20160628125621.GA9223@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"David S . Miller" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kama, Meirav" <meiravk@ti.com>
To: Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37993 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbcF1NFc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 09:05:32 -0400
In-Reply-To: <20160628125621.GA9223@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 15:56:21, Bob Copeland wrote:
> linux- wireless@vger.kernel.org; netdev@vger.kernel.org; Kama, Meirav
> Subject: Re: [PATCH 4/4] mac80211: sta_info: max_peers reached falsely
> 
> On Tue, Jun 28, 2016 at 02:13:07PM +0300, Yaniv Machani wrote:
> > From: Meirav Kama <meiravk@ti.com>
> >
> > Issue happened when receiving delete_sta command without changing 
> > plink_state from ESTAB to HOLDING before.
> > When receiving delete_sta command for mesh interface verify 
> > plink_state is not ESTAB and if so, decrease plink count and update 
> > beacon.
> 
> This should be fixed already (and properly) by the patch
> "mac80211: Fix mesh estab links counting" -- please let us know if you 
> have a case that's still broken with that fix.
> 

Thanks Bob,
Will be dropped.

Yaniv
> --
> Bob Copeland %% http://bobcopeland.com/
