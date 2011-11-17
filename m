From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 10:36:35 +0100
Message-ID: <20111117093635.GA9112@electric-eye.fr.zoreil.com>
References: <20111117064826.GA4429@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47533 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149Ab1KQJmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 04:42:02 -0500
Content-Disposition: inline
In-Reply-To: <20111117064826.GA4429@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang <junchangwang@gmail.com> :
> 
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Per cpu data is used to avoid lock operations.

The 816x chipsets have hardware stats registers. The driver already
use them. Please use them more.

-- 
Ueimor
