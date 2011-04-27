From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Wed, 27 Apr 2011 22:35:44 +0200
Message-ID: <20110427203544.GB19708@electric-eye.fr.zoreil.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com> <4DAFA9F9.5080909@hotmail.com> <4DB77D03.9070507@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59818 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759091Ab1D0Uoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 16:44:32 -0400
Content-Disposition: inline
In-Reply-To: <4DB77D03.9070507@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Lumby <johnlumby@hotmail.com> :
> Anyone have any further thoughts on the proposal to avoid
> memcpy'ing?  (see earlier post)

The patch mixes different changes. Please avoid it.

Your MUA damaged the patch. Documentation/SubmittingPatches
could help if you have not read it yet.

The patch makes some gratuitous changes which needlessly
increase the differences (dirty_xy rename for instance).

A set_ringparam() method which does nothing until open()
is used does not exactly ring like "least surprize behavior"
to me.

The behavior under memory pressure is still unknown.

I am mildly convinced by the implementation.

-- 
Ueimor
