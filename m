From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] r8169: fix invalid register dump
Date: Sat, 17 Aug 2013 23:14:07 +0200
Message-ID: <20130817211407.GA30676@electric-eye.fr.zoreil.com>
References: <1376730263-9352-1-git-send-email-lekensteyn@gmail.com>
 <1376735258.11042.102.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Wu <lekensteyn@gmail.com>, netdev@vger.kernel.org,
	nic_swsd <nic_swsd@realtek.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59089 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab3HQVOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 17:14:21 -0400
Content-Disposition: inline
In-Reply-To: <1376735258.11042.102.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> I would be very wary of accessing registers with any width other than
> the usual (32 bits).

You are right. Most registers do not seem to care - some are 8 bits
wide - but the 8168c datasheet states that it's out of spec for the
descriptor ring address registers.

Peter, please use Ben's suggestion as is.

-- 
Ueimor
