From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 3/4] bnx2: Remove some unnecessary smp_mb()
 in tx fast path.
Date: Mon, 19 Jul 2010 22:48:06 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B842BD27B@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1279604283.2458.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3243 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754632Ab0GTFsX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 01:48:23 -0400
In-Reply-To: <1279604283.2458.68.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Excellent,
>
> Is similar patch for tg3 planned ?
>

Yes, this performance issue was actually first discovered when
profiling a new tg3 device.  So Matt should be sending out a
very similar patch as part of his next patch-set.

