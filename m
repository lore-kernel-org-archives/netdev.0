From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Filtered data on Rx descriptor status context
Date: Mon, 10 Aug 2015 00:09:55 +0200
Message-ID: <20150809220955.GA12564@electric-eye.fr.zoreil.com>
References: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52732 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933193AbbHIWKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 18:10:15 -0400
Content-Disposition: inline
In-Reply-To: <1439121449-1835-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
>  We want to start evaluate an RES Receive error summary only 
>  when LS (LastFrag) occurred but without FirstFrag

No.

The driver does not care about fragmented rx frames (hint: RxMaxSize).

-- 
Ueimor
