From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 00/24] TRILL implementation
Date: Wed, 24 Sep 2014 22:57:52 +0200
Message-ID: <20140924205752.GC14754@electric-eye.fr.zoreil.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
 <20140924094422.2e710ead@urahara>
 <20140924165447.GG27183@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org,
	f.cachereul@alphalink.fr
To: William Dauchy <william@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41179 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaIXU5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:57:55 -0400
Content-Disposition: inline
In-Reply-To: <20140924165447.GG27183@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Dauchy <william@gandi.net> :
> On Sep24 09:44, Stephen Hemminger wrote:
[...]
> > Also, it seems when you build with trill you lose normal bridge functionality.
> > Whether kernel is doing bridge or rbridge has to be a runtime (not compile time)
> > choice on a per-bridge basis.
> 
> The normal bridge functionnality are still ok until TRILL is not
> enabled.

Imvho you should remove patch #24 and plug directly into br_handle_frame.
It is not fair for usual bridge interfaces to become second class
citizens - rbr_handle_frame _is_ unbalanced - as soon as CONFIG_TRILL is
set and they are not TRILL enabled.

-- 
Ueimor
