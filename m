From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Sat, 12 Jan 2008 11:53:02 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801121150001.16465@bizon.gios.gov.pl>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
 <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death>
 <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death>
 <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death>
 <20080109201709.GF8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-821302940-1200135182=:16465"
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:41849 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755439AbYALKx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 05:53:59 -0500
In-Reply-To: <20080109201709.GF8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-821302940-1200135182=:16465
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 9 Jan 2008, Andy Gospodarek wrote:
> On Wed, Jan 09, 2008 at 09:54:56AM -0800, Jay Vosburgh wrote:
<CUT>
>> =09This should silence the lockdep (if I'm understanding what
>> everybody's saying), and keep the change set to a minimum.  This might
>
> The lockdep problem is easy to trigger.  The lockdep code does a good
> job of noticing problems quickly regardless of how easy the deadlocks
> are to create.

Exactly. All I need to do is to reboot my server, I have 100% probability=
=20
to get the warning.

>> not even be worth pushing for 2.6.24; I'm not exactly sure how difficult
>> the lockdep problem would be to trigger.
>>
>
> I'd like to see it go in there (for correct-ness) and to avoid hearing
> about these lockdep issues for the next few months until it makes it
> into 2.4.25.

Right. So, what is the final patch? I would like to test it if that's=20
possible. ;)

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-821302940-1200135182=:16465--
