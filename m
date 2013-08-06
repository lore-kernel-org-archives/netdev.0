From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Make xfrm_state timer monotonic
Date: Tue, 6 Aug 2013 11:22:20 +0200
Message-ID: <20130806092220.GH25511@secunet.com>
References: <1375772225-19265-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41283 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755217Ab3HFJWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 05:22:23 -0400
Content-Disposition: inline
In-Reply-To: <1375772225-19265-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 02:57:05PM +0800, Fan Du wrote:
> xfrm_state timer should be independent of system clock change,
> so switch to monotonic clock base.
> 

I think a monotonic timer will reintroduce a bug on suspend/resume
that was fixed by commit 9e0d57fd6
(xfrm: SAD entries do not expire correctly after suspend-resume)

Please make sure that this does not happen.
