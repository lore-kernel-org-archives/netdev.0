From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 18 Jun 2009 08:21:12 -0700
Message-ID: <6599ad830906180821q2c357112s39c0da4e157b555c@mail.gmail.com>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	 <20090611.021347.142243970.davem@davemloft.net>
	 <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
	 <6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>
	 <20090615120035.a8b7b38f.usui@mxm.nes.nec.co.jp>
	 <20090615101919.GC7768@bombadil.infradead.org>
	 <20090617094907.e8cd77bd.usui@mxm.nes.nec.co.jp>
	 <4A399FF7.5060209@cn.fujitsu.com>
	 <20090618151516.73daf5d8.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Li Zefan <lizf@cn.fujitsu.com>, Thomas Graf <tgraf@infradead.org>,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	hadi@cyberus.ca, tgraf@suug.ch, David Miller <davem@davemloft.net>,
	jarkao2@gmail.com
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:8587 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889AbZFRPVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 11:21:17 -0400
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n5IFLF6J013436
	for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 16:21:15 +0100
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by spaceape10.eur.corp.google.com with ESMTP id n5IFL1WC019501
	for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 08:21:12 -0700
Received: by pzk5 with SMTP id 5so28255pzk.17
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2009 08:21:12 -0700 (PDT)
In-Reply-To: <20090618151516.73daf5d8.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 11:15 PM, Minoru Usui<usui@mxm.nes.nec.co.jp> wrote:
>
> net_cls.classid's core purpose is to read/write classid.
> If we add net_cls.tc_classid, its core purpose is same.
> Their difference is only read/write value of expression.

I still feel that it's unnecessary bloat to put that parsing/printing
logic in the kernel when userspace can do it just as easily. But
having it as a separate file would at least remove the compatibility
concerns.

Paul
