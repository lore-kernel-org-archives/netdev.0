From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic with bridge networking
Date: Thu, 12 Apr 2012 14:52:55 +0200
Message-ID: <1334235175.5300.6329.camel@edumazet-glaptop>
References: <4F86CACB.8010907@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Peter Huang (Peng)" <peter.huangpeng@huawei.com>
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45729 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933741Ab2DLMxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 08:53:00 -0400
Received: by wgbdr13 with SMTP id dr13so1970251wgb.1
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 05:52:59 -0700 (PDT)
In-Reply-To: <4F86CACB.8010907@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 14:30 +0200, Massimo Cetra wrote:
> Hello,
> 
> i am experiencing a panic whose logs are attached (grabbed with netconsole).
> 
> They look quite similar to what has been described here
>     http://www.spinics.net/lists/linux-net/msg17689.html
> 
> The patch proposed as the solution (commit 
> 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e) seems to be applied (even with 
> small differences) but the problem persists.
> 
> The kernel is a debian linux-image-3.2.0-2-amd64 version 3.2.12-1
> 
> Any hint ?
> I have checked the changelog of 3.2.13 and 3.2.14 and it doesn't seems 
> to be any commit regarding such problems.
> 
> Massimo Cetra
> 
> P.S.1: Please CC me as i'm not subscribed.
> P.S.2: this bug has been submitted to debian as well
>    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=668511
> 

Known issue, and we are waiting from a fix from Peter.

https://lkml.org/lkml/2012/3/31/17

Peter, any progress on your side ?

Thanks
