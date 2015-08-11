From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] gianfar: remove faulty filer optimizer
Date: Tue, 11 Aug 2015 11:41:31 -0700 (PDT)
Message-ID: <20150811.114131.1371626346368560494.davem@davemloft.net>
References: <1439237540-11302-4-git-send-email-moorray3@wp.pl>
	<BY2PR0301MB0727FA3B33977F2E64975F839C7F0@BY2PR0301MB0727.namprd03.prod.outlook.com>
	<20150811165109.0601035b@north>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	kubakici@wp.pl
To: moorray3@wp.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbHKSld convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 14:41:33 -0400
In-Reply-To: <20150811165109.0601035b@north>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jakub Kici=F1ski <moorray3@wp.pl>
Date: Tue, 11 Aug 2015 16:51:09 +0200

> On Tue, 11 Aug 2015 14:00:23 +0000, Manoil Claudiu wrote:
>> >-----Original Message-----
>> >From: Jakub Kicinski [mailto:moorray3@wp.pl]
>> >Sent: Monday, August 10, 2015 11:12 PM
>> >To: David S. Miller; Manoil Claudiu-B08782
>> >Cc: netdev@vger.kernel.org; Jakub Kicinski
>> >Subject: [PATCH 3/3] gianfar: remove faulty filer optimizer
>> >
>> >From: Jakub Kicinski <kubakici@wp.pl>
>> >
>> >Current filer rule optimization is broken in several ways:
>> > (1) It destroys rule ordering.
>> > (2) It performs reads/writes beyond end of allocated tables.
>> > (3) It breaks badly for rules with more than 2 specifiers
>> >     (e.g. matching ip, port, tos).
>> > (4) We observed that the masking rules it generates do not
>> >     play well with clustering on P2020.  Only first rule
>> >     of the cluster would ever fire.  Given that optimizer
>> >     relies heavily on masking this is very hard to fix.
>> >
>> >The fact that nobody noticed (1), (3) or (4) makes me think
>> >that this feature is not very widely used and we should just
>> >remove it.
>>=20
>> I'm not familiar with this filer classification code and its
>> author is no longer active apparently.   There is not much of a
>> choice here since this optimization feature is too complex and
>> poorly documented to be reviewed and validated in a reasonable
>> time span.
>> An example, a simple use case showing expected behavior vs.
>> actual behavior would help.
>=20
> Sure, sorry, should be part of the submission quite honestly...

I think removing this optimizer is the thing to do as well.

Please respin this patch series with the examples added to the
commit message of patch #3.

Thanks.
