From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Mon, 18 May 2015 05:54:09 -0700
Message-ID: <1431953649.621.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
	 <1431672946-300-3-git-send-email-ying.xue@windriver.com>
	 <1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150515.113950.1408734283430265055.davem@davemloft.net>
	 <55595B64.70702@windriver.com>
	 <1431925082.621.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55597EBD.8040002@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	alexei@purestorage.com, joern@purestorage.com, ja@ssi.bg
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:36481 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbERMyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:54:12 -0400
Received: by pdfh10 with SMTP id h10so148607088pdf.3
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 05:54:11 -0700 (PDT)
In-Reply-To: <55597EBD.8040002@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-18 at 13:55 +0800, Ying Xue wrote:

> So, exactly speaking, we cannot say neigh_add_timer() is completely wrong
> regarding your mentioned above assumption that neigh timer is absolutely not
> armed when neigh_add_timer() is called. But we can say its behaviour is not
> designed very well. From this point, the patch seems still a bit valuable for us.

Its design is correct.

We have to fix the caller that does not respect the proper convention.

So please try to understand the current logic, instead of changing
everything, and adding another bunch of bugs.
