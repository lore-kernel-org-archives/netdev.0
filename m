From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
Subject: Re: [PATCH] iproute2: Fix warnings with gcc 4.9 and clang 3.4
Date: Tue, 11 Mar 2014 03:30:37 +0000
Message-ID: <531E835D.2010903@draigBrady.com>
References: <284875ac93e0904c42a436cbf05cc57d@mail.lindev.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?QmVybmhhcmQgUm9zZW5rcsOkbnplcg==?= <bero@lindev.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754000AbaCKDat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 23:30:49 -0400
In-Reply-To: <284875ac93e0904c42a436cbf05cc57d@mail.lindev.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2014 02:00 AM, Bernhard Rosenkr=C3=A4nzer wrote:
> Hi,
> the latest compilers (gcc 4.9 and clang 3.4) issue warnings when doin=
g an incomplete struct initialization (e.g. "struct tc_sizespec s =3D {=
0};").
>=20
> Since many people like to compile lower level bits and pieces with -W=
error, this should probably be fixed. Patch attached.

Sounds like newer compilers are reverting:
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=3D36750
Hopefully not.

thanks,
P=C3=A1draig.
