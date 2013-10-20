From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCHSET net-next v3 00/07] Support for byte queue limits on
 various drivers
Date: Mon, 21 Oct 2013 00:07:19 +0200
Message-ID: <20131020220719.GA7493@electric-eye.fr.zoreil.com>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43622 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab3JTWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 18:11:23 -0400
Content-Disposition: inline
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tino Reichardt <milky-kernel@mcmilk.de> :
[...]
> this patchset is intended for net-next/linux-3.13.
> 
> It adds support for byte queue limits on various network drivers.
> 
> Since not all of them are fully tested by now, I added an bql_disable
> module parameter, which can be used to disable the BQL code.

(regarding the r8169 changes)

The module parameter is pointless: you previously said you tested the
r8169 changes, there is a whole release cycle ahead and we already
have enough kernels that can be choosen amongst if some specific
feature turns unexpectedly wrong.

This way you won't have to ponder if you should keep the original
author's Signed-off-by in the r8169 driver or not.

-- 
Ueimor
