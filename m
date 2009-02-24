From: Jeff Chua <jeff.chua.linux@gmail.com>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Tue, 24 Feb 2009 16:01:39 +0800
Message-ID: <b6a2187b0902240001s52d3e987pf1238816f9b59af7@mail.gmail.com>
References: <Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi>
	 <20090221.235308.172360407.davem@davemloft.net>
	 <b6a2187b0902232240m6f2347efs84639bb59a19269e@mail.gmail.com>
	 <20090223.224652.121864647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, herbert@gondor.apana.org.au,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:33825 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbZBXIBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 03:01:42 -0500
In-Reply-To: <20090223.224652.121864647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 2:46 PM, David Miller <davem@davemloft.net> wrote:
> Actually, it isn't.
>
> Herbert's change is in net-next-2.6 which will show up in linux-next
> rather than Linus's 2.6.29-rcX tree.
>

Uh, I got it wrong. Didn't look into details. Just noticed that
tcp_output.c was changed today, so I just assume that was the one ...
which turned out to a one-liner comment removed.

Anyway, I just tested the Herbert's patch and it looks good. rlogin not hanging.

Sorry for the earlier fault report.

Thanks
Jeff.
