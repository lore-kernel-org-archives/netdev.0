From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: enable napi on resume.
Date: Wed, 4 Apr 2012 01:03:17 +0200
Message-ID: <20120403230317.GA6165@electric-eye.fr.zoreil.com>
References: <1333484951-5432-1-git-send-email-artem.savkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Artem Savkov <artem.savkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38226 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753519Ab2DCXGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 19:06:41 -0400
Content-Disposition: inline
In-Reply-To: <1333484951-5432-1-git-send-email-artem.savkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Artem Savkov <artem.savkov@gmail.com> :
> NAPI is disabled during suspend and needs to be enabled on resume. Without
> this the driver locks up during resume in rtl_reset_work() trying to disable
> NAPI again.
> 
> Signed-off-by: Artem Savkov <artem.savkov@gmail.com>

:o(

It fixes runtime_{suspend / resume} as well.

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
