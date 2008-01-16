From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: questions on NAPI processing latency and dropped network
	packets
Date: Wed, 16 Jan 2008 23:42:44 +0100
Message-ID: <20080116224244.GA2626@ami.dom.local>
References: <20080115202905.GA2680@ami.dom.local> <E1JEvxs-0006cZ-00@gondolin.me.apana.org.au> <20080116065836.GA1638@ff.dom.local> <20080116200458.GC8953@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, cfriesen@nortel.com,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:32542 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754909AbYAPWj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 17:39:29 -0500
Received: by ug-out-1314.google.com with SMTP id z38so272680ugc.16
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 14:39:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080116200458.GC8953@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 09:04:58PM +0100, Willy Tarreau wrote:
...
> you can work with latest release provided that you always have a fallback
> to an earlier one. That way, you don't bet too much on something you don't
> completely control. If it works, it tells you you'll be able to completely
> exploit its new possibilities in next product release, and if it breaks,
> it's easy to issue a fix to get back to earlier, well-tested version.

Of course, this way looks preferable, but sometimes maybe too costly,
especially with some complex systems. Actually, I don't even think
this have to be fully (production ready) implemented or workable.
Probably there would be even enough to maintain some simplified kind
of test checking how current kernel changes could affect such a system,
and how new versions of this system are better, BTW.

Regards,
Jarek P.
