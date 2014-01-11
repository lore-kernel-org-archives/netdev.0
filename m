From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 06:07:04 -0800 (PST)
Message-ID: <1389449224.4533.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm40.bullet.mail.ne1.yahoo.com ([98.138.229.33]:23112 "EHLO
	nm40.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbaAKOKF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 09:10:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1/11/14, Christoph Paasch <christoph.paasch@uclouvain.be> wrote=
:

>> On 11/01/14 - 05:06:10, Fran=E7ois-Xavier Le Bail wrote:
>> On Sat, 1/11/14, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
>> As said in http://tools.ietf.org/html/draft-iab-anycast-arch-implica=
tions-12.html#section-2.1
>> (this informational draft is in RCF queue)

> This draft does not say that TCP should be used with anycast
> addresses. Rather the opposite:

> "  This document does not treat in any depth
>   the fact that there are deployed services with TCP transport using
>   anycast today.  Evidence exists to suggest that such practice is no=
t
>   "safe" in the traditional and architectural sense (as described in
>   Section 4.2). "

> And Section 4.2 gives more information.
> http://tools.ietf.org/html/draft-iab-anycast-arch-implications-12.htm=
l#section-4.2

The draft say there are use cases for TCP with anycast services.
The DNS use case is widely deployed in real word.

I think enabled such possibility in Linux kernel is useful.

It's only a possibility for such use cases and it's dont break usual TC=
P usage.

=46rancois-Xavier
