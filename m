From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Thu, 23 Apr 2009 20:43:19 +0200
Message-ID: <20090423184319.GB2756@ami.dom.local>
References: <1240489907.6554.110.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:44390 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbZDWSoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 14:44:23 -0400
Received: by fxm2 with SMTP id 2so710955fxm.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 11:44:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1240489907.6554.110.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Radu Rendec wrote, On 04/23/2009 02:31 PM:

> On Wed, 2009-04-22 at 23:29 +0200, Jesper Dangaard Brouer wrote:
...
>> The HTB classify hash has a scalability issue in kernels below 2.6.26. 
>> Patrick McHardy fixes that up in 2.6.26.  What kernel version are you 
>> using?
> 
> I'm using 2.6.26, so I guess the fix is already there :(

If Jesper meant the change of hash I can see it in 2.6.27 yet.

...
> In conclusion each packet would be matched against at most 1026 rules
> (worst case). The real case is actually much better: only one bucket
> with 400 rules, all other less than 70 rules and most of them less than
> 10 rules.

Alas I can't analyze this all now, and probably I miss something, but
your worst and real cases look suspiciously big. Do all these classes
differ so much? Maybe you should have a look at cls_flow?

Jarek P.
