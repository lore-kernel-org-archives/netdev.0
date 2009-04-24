From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 24 Apr 2009 06:01:16 +0000
Message-ID: <20090424060116.GA4374@ff.dom.local>
References: <20090423184319.GB2756@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:53591 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538AbZDXGBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 02:01:25 -0400
Received: by qw-out-2122.google.com with SMTP id 5so791320qwd.37
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 23:01:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090423184319.GB2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23-04-2009 20:43, Jarek Poplawski wrote:
> Radu Rendec wrote, On 04/23/2009 02:31 PM:
...
>> In conclusion each packet would be matched against at most 1026 rules
>> (worst case). The real case is actually much better: only one bucket
>> with 400 rules, all other less than 70 rules and most of them less than
>> 10 rules.
> 
> Alas I can't analyze this all now, and probably I miss something, but
> your worst and real cases look suspiciously big. Do all these classes
> differ so much? Maybe you should have a look at cls_flow?

Actually fixing this u32 config (hashes) should be enough here.

Jarek P.
