From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Wed, 13 Nov 2013 15:40:40 -0800
Message-ID: <1384386040.28458.143.camel@edumazet-glaptop2.roam.corp.google.com>
References: <8761s0cqhh.fsf@natisbad.org>
	 <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site>
	 <87y54u59zq.fsf@natisbad.org>
	 <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8738n0ngq3.fsf@natisbad.org>
	 <pan.2013.11.13.21.59.50.578858@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38801 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075Ab3KMXkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 18:40:41 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj1so1190280pad.21
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 15:40:41 -0800 (PST)
In-Reply-To: <pan.2013.11.13.21.59.50.578858@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 22:59 +0100, Holger Hoffstaette wrote:

> +1: fixes spastic NFS & Samba throughput since 3.12.0 with r8169 and e100e
> for me as well. It's really not just broken/weird Wifi cards that are
> affected by this.

Same remark, it would be nice to pinpoint the problematic driver.

e1000e had a problem last year, fixed in commit 
8edc0e624db3756783233e464879eb2e3b904c13
("e1000e: Change wthresh to 1 to avoid possible Tx stalls")

We can live with the current situation and continue to fill buffers
to work around bugs, or we can try to fix the bugs ;)

Thanks
