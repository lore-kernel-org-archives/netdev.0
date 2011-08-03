From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: bonding and ifenslave version.
Date: Wed, 03 Aug 2011 08:43:47 +0200
Message-ID: <4E38EE23.8030703@gmail.com>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40336 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab1HCGnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 02:43:50 -0400
Received: by wyg8 with SMTP id 8so319042wyg.19
        for <netdev@vger.kernel.org>; Tue, 02 Aug 2011 23:43:49 -0700 (PDT)
In-Reply-To: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/08/2011 22:06, Nicolas de Peslo=C3=BCan a =C3=A9crit :
> Commit 655f8919d549ad1872e24d826b6ce42530516d2e
>      bonding: add min links parameter to 802.3ad
>
> and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
>      bonding: add all_slaves_active parameter
>
> introduced new options to bonding, but didn't provide the documentati=
on
> for those options.
>
> Signed-off-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
> ---

Jay, Andy,

While working at this patch, I noticed that the bonding driver version =
wasn't bumped up at the time=20
those options were introduced.

I thought introducing a new option should cause the driver version to c=
hange. Am I right?

On a different but related topic, the version in Documentation/networki=
ng/ifenslave.c (1.1.0) didn't=20
change since the git origin and probably since 2003.

Arguably, none of the commit regarding this file introduced a significa=
nt change (with the possible=20
exception of commit e6d184e33109010412ad1d59719af74755a935f4, [NET]: Fi=
x ifenslave to not fail on=20
lack of IP information). But if we never change a 3-level version numbe=
r, whatever the level of=20
change, this version number might be useless. Any comment?

	Nicolas.
