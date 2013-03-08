From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net/rds: zero last byte for strncpy
Date: Fri, 08 Mar 2013 14:13:23 +0800
Message-ID: <51398183.5090800@asianux.com>
References: <51356FED.4070909@asianux.com> <1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com> <513958C4.1020404@asianux.com> <20130308.003630.1150878411855053823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, David.Laight@ACULAB.COM,
	venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:31459 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880Ab3CHGNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 01:13:47 -0500
In-Reply-To: <20130308.003630.1150878411855053823.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8808=E6=97=A5 13:36, David Miller =E5=86=
=99=E9=81=93:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Fri, 08 Mar 2013 11:19:32 +0800
>=20
>>
>>   for NUL terminated string, need be always sure '\0' in the end.
>>
>> additional info:
>>   strncpy will pads with zeroes to the end of the given buffer.
>>   should initialise every bit of memory that is going to be copied t=
o userland
>>
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>=20
> Applied.
>=20
>=20

  thanks.

--=20
Chen Gang

Asianux Corporation
