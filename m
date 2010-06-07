From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix random mdio_write failures
Date: Mon, 7 Jun 2010 23:51:15 +0200
Message-ID: <20100607215115.GA6583@electric-eye.fr.zoreil.com>
References: <4C0A1736.9030209@iki.fi>
 <1275733273-28321-1-git-send-email-timo.teras@iki.fi>
 <20100605124103.GA3213@electric-eye.fr.zoreil.com>
 <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Timo =?utf-8?Q?Ter=C3=A4s'?=" <timo.teras@iki.fi>,
	netdev@vger.kernel.org, davem@davemloft.net
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.185.140-88.rev.gaoland.net ([88.140.185.30]:50980 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752431Ab0FGVvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 17:51:41 -0400
Content-Disposition: inline
In-Reply-To: <4C31B2E3BE2B481DB749C669DFE23645@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
> Our hardware engineer suggests that check the completed indication
> per 100 micro seconds. And it needs 20 micro seconds delay after the 
> completed indication for the next command.

Should we do the same for mdio_read as well (100 us per iteration + 
an extra 20 us) ?

-- 
Ueimor
