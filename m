From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 1/7] r8169: adjust some registers
Date: Thu, 7 Jul 2011 10:50:15 +0200
Message-ID: <20110707085015.GA5320@electric-eye.fr.zoreil.com>
References: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51562 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab1GGJE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:04:29 -0400
Content-Disposition: inline
In-Reply-To: <1309939088-31994-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
[...]

I have acked and pushed the whole serie against davem's -next branch
(aec27311c23a8ce8eaf490762249d3ed74be83b6) as :

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

I have done three changes which do imho not deserve a separate patch:
- renamed rtl_eri_write_w0w1 to rtl_w1w0i_eri as there already is a
  rtl_w1w0_phy. Parameters have been permuted (idem for callers).
- fixed spurious static<space><space> and excess comment line length.

I am giving it a pair of hours testing.

-- 
Ueimor
