From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 1/2] bnx2x: add support for ndo_ll_poll
Date: Tue, 18 Jun 2013 04:15:43 -0700
Message-ID: <1371554143.3252.253.camel@edumazet-glaptop>
References: <1371541333-19225-1-git-send-email-dmitry@broadcom.com>
	 <1371541333-19225-2-git-send-email-dmitry@broadcom.com>
	 <1371543058.3252.214.camel@edumazet-glaptop>
	 <504C9EFCA2D0054393414C9CB605C37F20CBC237@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:43925 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab3FRLPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 07:15:48 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so2414678eaf.6
        for <netdev@vger.kernel.org>; Tue, 18 Jun 2013 04:15:47 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20CBC237@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-18 at 10:45 +0000, Dmitry Kravkov wrote:

> > Ideally, we could keep a counter of enabled LLS sockets, to
> > automatically switch off/on GRO, but in net/core, not in every driver.
> 
> Since we have GRO in FW it will be hard to disable/enable it on the fly, probably better  to return LL_FLUSH_FAILED when GRO is enabled?

Yes, assuming GRO in FW means latencies ?

(If we receive a frame, FW has to wait a bit for the following frames to
eventually aggregate them)

I thought FW did LRO part on bnx2x, and GRO was the software thing (in
networking core, not in the bnx2x drivre)
