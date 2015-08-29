From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, net-next] r8169: Deny functions membet of array rtl_work
Date: Sat, 29 Aug 2015 13:26:30 +0200
Message-ID: <20150829112630.GA8873@electric-eye.fr.zoreil.com>
References: <1440845029-3079-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43754 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbbH2L0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 07:26:55 -0400
Content-Disposition: inline
In-Reply-To: <1440845029-3079-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
> Deny functions member of array rtl_work to run when link  is
> ok.After rtl8169_init_phy exist 10 sec  timeout.On many  cases link is ok and
> no need to destroy all work.

I won't figure what happens outside of the "many cases" statement.

rtl_reset_work is a hard reset. It isn't supposed to go shopping just
because the link seems to be established. Moreover you don't explain why
you need to vandalize rtl_phy_work (unrelated to any 10 sec timeout).

As usual nobody knows how it was tested (suspend/resume, change location
and port, etc.).

Please don't send me private only e-mail.

-- 
Ueimor
