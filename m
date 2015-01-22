From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: NULL pointer dereference at skb_queue_tail()
Date: Thu, 22 Jan 2015 21:18:12 +0900
Message-ID: <201501222118.IJG12977.HVLFFMSJFOQtOO@I-love.SAKURA.ne.jp>
References: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
	<201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
	<CAHA+R7Mq=vhSCqJsE5dn7PGg39R8Nh+m1RT0F-KcoBU99GdpWA@mail.gmail.com>
	<201501092220.DIB43754.FFMQOSJLOOHVtF@I-love.SAKURA.ne.jp>
	<1420818314.5947.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cwang@twopensource.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:57190 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbbAVMSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 07:18:24 -0500
In-Reply-To: <1420818314.5947.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Fri, 2015-01-09 at 22:20 +0900, Tetsuo Handa wrote:
> 
> > Would you tell me which versions to test?
> 
> Could you do a bisection ?
> 
> I do not see obvious bugs in af_unix.c, so it might be a corruption from
> another part of the code, reusing a freed skb.
> 

It looks like a bug in drm subsystem. Thank you.
http://lists.freedesktop.org/archives/dri-devel/2015-January/075922.html
