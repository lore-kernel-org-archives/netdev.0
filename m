From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [BUG] bnx2x : lockdep assertion
Date: Mon, 06 Jan 2014 08:49:34 -0800
Message-ID: <1389026974.12212.180.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
	 <1388939634-19948-3-git-send-email-yuvalmin@broadcom.com>
	 <1389025680.12212.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6AE768456CEC4B4A9B2248CB6B87EB3E1BFBE6A6@SJEXCHMB05.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michal Kalderon <michal.spivak@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:54961 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755628AbaAFQth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 11:49:37 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so18502203pde.27
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 08:49:37 -0800 (PST)
In-Reply-To: <6AE768456CEC4B4A9B2248CB6B87EB3E1BFBE6A6@SJEXCHMB05.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-06 at 16:35 +0000, Ariel Elior wrote:

> Hi Eric,
> This was introduced by the low latency patch which added a 'might_sleep()' to napi_disable a while ago.
> There is a fix in the works.
> Thanks,

Hmm, commit 80c33ddd31d0e801953 is 3 months old.

Do you have an idea of ETA for the fix ?

Thanks !
