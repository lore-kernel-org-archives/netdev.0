From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] Fix copy-paste bug: assign from src struct not dest
Date: Wed, 07 Jan 2015 23:16:18 +0100
Message-ID: <1420668978.3407.28.camel@sipsolutions.net>
References: <20150107191836.GA18978@salidar.dom.custoft.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>,
	linux-kernel@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: Giel van Schijndel <me@mortis.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38153 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539AbbAGWQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 17:16:40 -0500
In-Reply-To: <20150107191836.GA18978@salidar.dom.custoft.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-07 at 20:18 +0100, Giel van Schijndel wrote:

> IMO the aligned block of code has the significant advantage of taking
> advantage of humans' ability to spot things that break a pattern. Which
> in this case becomes *very* visible when properly aligned, because
> without the alignment there is no (visual) pattern (or at least not one
> very suitable for my "visual processing system", I know the same applies
> to at least some others).

Yeah, well, but why even invoke that "visual processing system"?

If you look, for example, at the __skb_clone function it just uses a
macro:

#define C(x) n->x = skb->x

and then

	C(len);
	C(data_len);

etc.

johannes
