From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 10:42:48 +0100
Message-ID: <20080116094248.GC2307@ff.dom.local>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net> <20080116080259.GB1638@ff.dom.local> <478DBADB.1080200@trash.net> <478DC1D7.90401@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:17606 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbYAPJg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 04:36:26 -0500
Received: by mu-out-0910.google.com with SMTP id i10so249419mue.5
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 01:36:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478DC1D7.90401@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 11:35:35AM +0300, Badalian Vyacheslav wrote:
...
> I simple recreate all rules. I change idea from do many add,change,delete 
> because have many kernel panics on many kernels 2.6.x
> First i have panics on "delete filter" operation... was fix it... great.. 
> then have panics on "delete htb" operation... long time wait to fix it 
> (maintainer of tc not have time to fix it i think).. but have 1-5 panics at 
> day.... i think my clients hate  me =) i rewrite script to simple  recreate 
> all rules... in this method i have small packetlost 1 time in hour (then 
> recreate root qdisc), but not have panics... now i use new logic of 
> scripts... =)
> maybe need go back to accurate logic of scripts, but i to fear kernel 
> panics =)

BTW, I don't know about others, but it seems this bugzilla #9632 waits
for your testing, to find the reason of this bug... IMHO, if you can't
try this now, it's better to close this or/and at least add some
comment. And if there are any other bugs unfixed which are
reproducible and you can test (or have tested) some patches, please
resend them as new threads to the list. Alas, omitting the panics
can't help in removing these bugs.

Jarek P.
