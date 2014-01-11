From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 06:16:10 -0800 (PST)
Message-ID: <1389449770.4912.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <CAMrnHh76D1d_JrXhtz+nvJP+Aiux2iPW+5uVZqQpbmWbQG0=OQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm32.bullet.mail.ne1.yahoo.com ([98.138.229.25]:34330 "EHLO
	nm32.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751466AbaAKOTH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 09:19:07 -0500
In-Reply-To: <CAMrnHh76D1d_JrXhtz+nvJP+Aiux2iPW+5uVZqQpbmWbQG0=OQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1/11/14, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

Hello,

> Actually, I was alerted by reset processing in your patch, it cannot be right.

Did I miss something, please explain why there is an error.

> Do not you think this must not be enabled for common use? At least
> some separate sysctl disabled by default.

Why not ? But if a patch can enable anycast case without break "normal" usage,
I think we can enable this by default. Those who don't need anycast will not use it.
