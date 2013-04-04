From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match
 'if' and 'switch' statement.
Date: Thu, 04 Apr 2013 17:05:23 +0800
Message-ID: <515D4253.5040205@asianux.com>
References: <515C303B.1040304@asianux.com> <20130403140823.GB3401@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:56810 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab3DDJFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 05:05:54 -0400
In-Reply-To: <20130403140823.GB3401@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8803=E6=97=A5 22:08, Michal Kubecek wrote:
> On Wed, Apr 03, 2013 at 09:35:55PM +0800, Chen Gang wrote:
>> >=20
>> > in drivers/isdn/isdnloop/isdnloop.c
>> >=20
>> >   issue description:
>> >     it is in function 'isdnloop_command'.
>> >     it seems a C grammar issue for '}' miss match 'if' and 'switch=
' statement
>> >     please check the line 1243, 1265, 1341.
>> >=20
>> >   building:
>> >     make allyesconfig, can not let it built.
>> >     in menuconfig, we (at least for me) can not let ISDN_DRV_LOOP =
=3D 'y' or 'm'.
>> >     is this module a waste module which should be deleted ?
>> >=20
>> >   the related commit:
>> >     commit 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2
>> >     Author: Linus Torvalds <torvalds@ppc970.osdl.org>
>> >     Date:   Sat Apr 16 15:20:36 2005 -0700
> As far as I can see, this rather comes from
>=20
> commit 475be4d85a274d0961593db41cf85689db1d583c
> Author: Joe Perches <joe@perches.com>
> Date:   Sun Feb 19 19:52:38 2012 -0800

  Joe Perches only beautified the code, not change the contents.

  please check thanks.


--=20
Chen Gang

Asianux Corporation
