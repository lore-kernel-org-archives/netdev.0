From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 14:06:11 +0000
Message-ID: <20090120140611.GC17004@ff.dom.local>
References: <20090115.153449.204259387.davem@davemloft.net> <20090115234255.GE1123@1wt.eu> <20090115234408.GA1693@1wt.eu> <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu> <4975BD09.3020103@zeus.com> <20090120121115.GA17277@ioremap.net> <4975D518.1000800@zeus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>, Willy Tarreau <w@1wt.eu>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dada1@cosmosbay.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Ben Mansell <ben@zeus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f20.google.com ([209.85.219.20]:53695 "EHLO
	mail-ew0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbZATOGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 09:06:18 -0500
Content-Disposition: inline
In-Reply-To: <4975D518.1000800@zeus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 01:43:52PM +0000, Ben Mansell wrote:
...
> With an unpatched kernel, the splice performance was worse (due to the  
> one packet per-splice issues). With the small patch to fix that, I was  
> getting around 2 Gbps performance, although oddly enough, I could only  
> get 2 Gbps with read()/write() then as well...
>
> I'll try and do some tests on a machine that hopefully doesn't have the  
> bottlenecks (and one that uses different NICs)

I guess you should especially check if SG and checksums are on, and it
could depend on a chip within those NICs as well.

Jarek P. 
