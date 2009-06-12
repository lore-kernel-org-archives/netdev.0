From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Fri, 12 Jun 2009 12:40:28 +0900
Message-ID: <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	<20090611.021347.142243970.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, jarkao2@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:59012 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZFLEaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 00:30:09 -0400
In-Reply-To: <20090611.021347.142243970.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, David

Thank you for your comments.

On Thu, 11 Jun 2009 02:13:47 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Minoru Usui <usui@mxm.nes.nec.co.jp>
> Date: Thu, 11 Jun 2009 18:05:55 +0900
> 
> > This patch unifies classid syntax of cls_cgroup to tc.
> 
> Won't this break existing users?
> 
> We really can't say "oh sorry" and change things after it's
> been effectively deployed already.

It's true. If my patch applied, old syntax can't use.
But I think compatibility is important, too.
So I'll make a new patch which can use both old and new syntax, when we write classid to net_cls.classid file.

Present implementation is an asymmetry with read and write.(read: decimal, write: hexadecimal)
I think this might be interface bug, so I think we should unify to read/write syntax. 
Of course, if read syntax change from decimal expression, there isn't compatibility.
But I think it's better to fix this problem. 
What do you think?

If it's ok, I'd like to be able to use tc syntax(X:Y style),
because cls_cgroup's purpose is select class which create by tc command.
tc command can only use classid syntax X:Y style, so we should be able to use X:Y style to cls_cgroup. 
-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
