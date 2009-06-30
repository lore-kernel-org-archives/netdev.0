From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 09:23:44 +0000
Message-ID: <20090630092344.GA8592@ff.dom.local>
References: <20090630085706.GD5589@ff.dom.local> <4A49D872.5050403@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:42256 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628AbZF3JXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 05:23:47 -0400
Received: by bwz9 with SMTP id 9so3760738bwz.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 02:23:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A49D872.5050403@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 01:18:42PM +0400, Badalian Vyacheslav wrote:
> Jarek Poplawski ??????????:
> > On 30-06-2009 10:12, Badalian Vyacheslav wrote:
...
> >> tc qdisc add dev eth0 root handle 1 htb default 7
> >> class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit
> >> prio 3
> >> qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
> >> # all normal
> >> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys
> >> src,dst
> >> # all traffic drop
> >>
> >>     
> >
> >   
> Yep. I was read this commit and create example based on it.
> My question why its drop all traffic after add flow filter? Its simple
> must group traffic to sfq qidsc by HASH like equal cost routing by KEY
> if i understand. I need balance traffic in class/qdisc by KEY, but not
> by sessions.
> 
> Any worked example will be great. In commit i see only syntax :)

Any non-working example with this syntax? (divisor?)

Jarek P.
> 
> > Here are some hints (if we don't mention google ;-)
> > http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.29.y.git;a=commitdiff;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe
> >
> > Regards,
> > Jarek P.
> >
> >
> >   
> 
