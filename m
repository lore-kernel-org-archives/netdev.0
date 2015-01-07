From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sched: use pinned timers
Date: Wed, 07 Jan 2015 07:45:49 -0800
Message-ID: <1420645549.5947.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411261290.26859.103.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140926.002710.1595423408687413602.davem@davemloft.net>
	 <54AD0543.1090806@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cosmin GIRADU <cosmin.giradu@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:49288 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639AbbAGPpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 10:45:52 -0500
Received: by mail-pd0-f174.google.com with SMTP id fp1so5328858pdb.5
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 07:45:51 -0800 (PST)
In-Reply-To: <54AD0543.1090806@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-07 at 12:06 +0200, Cosmin GIRADU wrote:

> Hi Eric,
> 
>     I saw that this patch didn't make it's way into the stable branches.
> So I have two questions:
>         - Would it be safe to apply to linux-3.12.x stable?
>         - If yes, would there be any [noticeable] efects on a [pretty
> complex] HTB setup? (I know, test and I'll see,
>            but if theory sais I won't, then there would be no point to
> the test, would there?)
> 

It is safe to backport.

If you want to test an equivalent, without kernel patch, you simply can
do :

echo 0 >/proc/sys/kernel/timer_migration
