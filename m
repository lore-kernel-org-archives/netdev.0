From: =?utf-8?B?RnJhbsOnb2lzLVhhdmllciBMZSBCYWls?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH] ipv6 addrconf: source address selection, Rule 7: Prefer temporary addresses (RFC 6724)
Date: Wed, 4 Dec 2013 06:29:46 -0800 (PST)
Message-ID: <1386167386.3192.YahooMailBasic@web125505.mail.ne1.yahoo.com>
References: <20131201.202237.1289362147164597952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm31.bullet.mail.ne1.yahoo.com ([98.138.229.24]:32856 "HELO
	nm31.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932165Ab3LDOcc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 09:32:32 -0500
In-Reply-To: <20131201.202237.1289362147164597952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Monday, December 2, 2013 2:25 AM, David Miller <davem@davemloft.ne=
t> wrote:

>> From: fx.lebail@yahoo.com
>> Date: Mon, 25 Nov 2013 17:16:45 +0100
>>  The RFC 6724 change the default recommendation for source address s=
election
>>  Rule 7 to prefer temporary addresses rather than public addresses,
>>  while providing an administrative override.
>>
>>  The administrative override is based on the prefer_src_public sysct=
l.
>>
>>  Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
>
> I think we need to preserve existing behavior, but this patch does no=
t
> do that.
>
> Sorry, I can't apply this.
>
> If someone was depending upon the old preferencing in some way, we wi=
ll
> break communications for them, and that really isn't acceptable.
>
> It's really ill advised for the RFC folks to create situations like
> this, where implementations have to choose between following the
> updated RFC to the letter and keeping existing setups working.

The change is explained here: http://tools.ietf.org/html/rfc6724#append=
ix-B

=E2=80=9C This change was made because of the increasing
  importance of privacy considerations, as well as the fact that
  widely deployed implementations have preferred temporary
  addresses for many years without major application issues.=E2=80=9D
