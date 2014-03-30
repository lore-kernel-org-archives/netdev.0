From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: new leaks in bridging code.
Date: Sun, 30 Mar 2014 11:28:21 +0900
Message-ID: <1396146501.2182.5.camel@localhost.localdomain>
References: <533730f2396e8_1c4bb46874192e@209.249.196.67.mail>
	 <20140329210102.GA22516@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, makita.toshiaki@lab.ntt.co.jp
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:41065 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbaC3C21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 22:28:27 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so6695708pbc.9
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2014 19:28:26 -0700 (PDT)
In-Reply-To: <20140329210102.GA22516@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-03-29 at 17:01 -0400, Dave Jones wrote:
> yesterdays bridging changes introduced leaks in the exit paths..
> 
The patch has nothing to do with this memory leak.
It has existed since br_allowed_ingress was introduced.
I'm working on fixing it.
http://marc.info/?t=139598775400004&r=1&w=2

Thanks,
Toshiaki Makita
