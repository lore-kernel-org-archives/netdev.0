From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: tc filter ouput, no filter hits?
Date: Sat, 29 Dec 2012 05:55:29 -0800
Message-ID: <1356789329.21409.3932.camel@edumazet-glaptop>
References: <1356788777.97050.YahooMailNeo@web165006.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: julius <commercials22@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:58853 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2L2Nzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 08:55:31 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so5163579dac.40
        for <netdev@vger.kernel.org>; Sat, 29 Dec 2012 05:55:31 -0800 (PST)
In-Reply-To: <1356788777.97050.YahooMailNeo@web165006.mail.bf1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-12-29 at 05:46 -0800, julius wrote:
> hi,
> 
> ive seen some examples where the output from:
> tc -s filter show dev ifb0 parent 1: 
> shows a filter hit count, like the output shown below:
> 
> filter protocol ip pref 1 u32
> filter protocol ip pref 1 u32 fh 800: ht divisor 1
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 
> 1:1  (rule hit 2 success 0)
> 
> 
> 
> however in my openwrt 12.09 and on my ubuntu machine i dont see the part in the paranthese, why is that?
> 
> ubuntu:
> iproute (20120521-3ubuntu1)
> 3.2.0-23-generic #36-Ubuntu
> 

Because its optional, kernel compilation needs :

CONFIG_CLS_U32_PERF=y
