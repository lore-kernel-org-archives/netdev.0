From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: Re: Kernel panic with bridge networking
Date: Fri, 13 Apr 2012 10:45:39 +0800
Message-ID: <004301cd191f$83145200$893cf600$%huangpeng@huawei.com>
References: <4F86CACB.8010907@navynet.it>
 <1334235175.5300.6329.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	'Massimo Cetra' <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([58.251.152.66]:36704 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086Ab2DMCpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 22:45:47 -0400
Received: from huawei.com (szxga03-in [172.24.2.9])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M2E0081QD086B@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Fri, 13 Apr 2012 10:45:44 +0800 (CST)
Received: from szxrg01-dlp.huawei.com ([172.24.2.119])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M2E003OED08UY@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Fri, 13 Apr 2012 10:45:44 +0800 (CST)
In-reply-to: <1334235175.5300.6329.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric

Sorry for delayed reply.
I will send the patch out until tomorrow .

--------------------------------
Peter Huang(peng)


> On Thu, 2012-04-12 at 14:30 +0200, Massimo Cetra wrote:
> > Hello,
> >
> > i am experiencing a panic whose logs are attached (grabbed with netconsole).
> >
> > They look quite similar to what has been described here
> >     http://www.spinics.net/lists/linux-net/msg17689.html
> >
> > The patch proposed as the solution (commit
> > 6b1e960fdbd75dcd9bcc3ba5ff8898ff1ad30b6e) seems to be applied (even with
> > small differences) but the problem persists.
> >
> > The kernel is a debian linux-image-3.2.0-2-amd64 version 3.2.12-1
> >
> > Any hint ?
> > I have checked the changelog of 3.2.13 and 3.2.14 and it doesn't seems
> > to be any commit regarding such problems.
> >
> > Massimo Cetra
> >
> > P.S.1: Please CC me as i'm not subscribed.
> > P.S.2: this bug has been submitted to debian as well
> >    http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=668511
> >
> 
> Known issue, and we are waiting from a fix from Peter.
> 
> https://lkml.org/lkml/2012/3/31/17
> 
> Peter, any progress on your side ?
> 
> Thanks
