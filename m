From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 20:39:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0806032036070.3438@bizon.gios.gov.pl>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl>
 <20080603113343.GA4714@ff.dom.local> <48453C70.1040303@trash.net>
 <Pine.LNX.4.64.0806031449540.3438@bizon.gios.gov.pl> <484542B5.4070401@trash.net>
 <Pine.LNX.4.64.0806031617310.3438@bizon.gios.gov.pl> <48458D59.5030101@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1943991214-1212518379=:3438"
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: davem@davemloft.net, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:42315 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbYFCSjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 14:39:55 -0400
In-Reply-To: <48458D59.5030101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1943991214-1212518379=:3438
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 3 Jun 2008, Patrick McHardy wrote:

> Krzysztof Oledzki wrote:
>> On Tue, 3 Jun 2008, Patrick McHardy wrote:
>>=20
>>> I think the proper solution is what I wrote in the changelog
>>> entry: fix userspace applications when using extended table
>>> IDs.
>>=20
>> It is unquestionably true, however it may take some time and people may=
=20
>> still use old version of such applications for whatsoever reasons.
>>=20
>>> Your patch makes it more predictable, so I'm not completely
>>> opposed, but still its just a workaround.
>>=20
>> Indeed - it is a workaround but I believe we need it.
>
> I'm neither opposed (as long as we don't add CONFIG options for
> this) nor in favour - people using fixed applications won't notice,
> and for other people it substitutes undesired behaviour by more
> predictable undesirable behaviour,

Exactly,

> which is at least no loss :)

OK, so I assume it is a very weak ack-by? ;)

David?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1943991214-1212518379=:3438--
