From: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Thu, 22 Nov 2007 16:25:22 +0100
Message-ID: <200711221625.22544.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:49076 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbXKVPoW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2007 10:44:22 -0500
Received: from mailhub.studentenwerk.mhn.de (mail.studentenwerk.mhn.de [10.148.7.34])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 119AD5800B
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2007 16:25:23 +0100 (CET)
Received: from mist.as.studentenwerk.mhn.de (mist.as.studentenwerk.mhn.de [10.148.0.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailhub.studentenwerk.mhn.de (Postfix) with ESMTP id 0F7EE9FB54
	for <netdev@vger.kernel.org>; Thu, 22 Nov 2007 16:25:23 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Patrick McHardy

> I'm working on the incremental ruleset changing API BTW :)
> One of the changes will be that interface matching is not
> a default part of every rule, and without wildcards it will
> use the ifindex. But since the cost of this feature seems
> pretty low, I don't see a compelling reason against it.

Using ifindex instead of string matching the interface name in -i and -=
o
 would be a serious problem as it changes the semantics.

1) Now you can match a non existing interface. This is certainly used. =
I.e.
with vlan interfaces, ppp etc.
2) Now your rule will match an interface even if the ifindex of the int=
erface
changes. This is used (i.e. you activate a backup interface and rename =
it,
build new bridges etc.).

If one wants to use the ifindex instead of a string match on the name o=
ne
should explicitly request that (i.e. by using "-i =3Deth0" or something=
 like
that).

Regards,
--
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
