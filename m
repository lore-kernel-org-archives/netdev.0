From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 08:57:06 +0000
Message-ID: <20090630085706.GD5589@ff.dom.local>
References: <4A49C906.9010102@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:58093 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456AbZF3I5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 04:57:08 -0400
Received: by fg-out-1718.google.com with SMTP id e21so1063473fga.17
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 01:57:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A49C906.9010102@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-06-2009 10:12, Badalian Vyacheslav wrote:
> Hello all.
> Sorry for mail to this maillist, but in internet i can't found any
> information to understand this situation, lartc list is dead, function
> do not documented and only developers understand how it works.

They only pretend they understand how it works...

> 
> As i understand if i add flow hash i divide speed to KEYs (example to
> dst) not for sessions right?
> 
> Why if i add simple example my traffic stop and i get DROP at parent class?
> 
> This my sample
> 
> tc qdisc add dev eth0 root handle 1 htb default 7
> class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit
> prio 3
> qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
> # all normal
> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys
> src,dst
> # all traffic drop
> 

Here are some hints (if we don't mention google ;-)
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.29.y.git;a=commitdiff;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe

Regards,
Jarek P.
