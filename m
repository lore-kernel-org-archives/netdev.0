From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference at skb_queue_tail()
Date: Fri, 09 Jan 2015 07:45:14 -0800
Message-ID: <1420818314.5947.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
	 <201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
	 <CAHA+R7Mq=vhSCqJsE5dn7PGg39R8Nh+m1RT0F-KcoBU99GdpWA@mail.gmail.com>
	 <201501092220.DIB43754.FFMQOSJLOOHVtF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:63177 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757768AbbAIPpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 10:45:16 -0500
Received: by mail-ie0-f175.google.com with SMTP id x19so15567822ier.6
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 07:45:16 -0800 (PST)
In-Reply-To: <201501092220.DIB43754.FFMQOSJLOOHVtF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-01-09 at 22:20 +0900, Tetsuo Handa wrote:

> Would you tell me which versions to test?

Could you do a bisection ?

I do not see obvious bugs in af_unix.c, so it might be a corruption from
another part of the code, reusing a freed skb.
