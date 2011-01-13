From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH] ipv4: devconf: start IPV4_DEVCONF_* from 0
Date: Thu, 13 Jan 2011 14:23:41 +0200
Message-ID: <AANLkTi=jRKjxCJ+LitX5TaqxWakj39DM37hGUw_rJG4H@mail.gmail.com>
References: <AANLkTin1LCgEpBNay_o4dzF1ONKanR1HRqcOu3AqqyHu@mail.gmail.com>
 <20110112.184734.38051229.davem@davemloft.net> <AANLkTimLyNf-sgLtzf0i3k7om9MEQ2t8tSOwDcpS66dv@mail.gmail.com>
 <20110113100224.GB30432@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@li
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57990 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756576Ab1AMMYC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 07:24:02 -0500
Received: by iwn9 with SMTP id 9so1504693iwn.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 04:24:01 -0800 (PST)
In-Reply-To: <20110113100224.GB30432@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 12:02 PM, Thomas Graf <tgraf@infradead.org> wro=
te:
> On Thu, Jan 13, 2011 at 09:50:14AM +0200, Lucian Adrian Grijincu wrot=
e:
>> Yes it works, but there does not seem to be a good reason why to
>> complicate things like this (again the sentinel nature of zero is no=
t
>> used in any place here).
>
> I have no objects to changing this at all but we don't gain much eith=
er.


Should I post a new patch in which IFLA_INET_CONF cfgid values start
from 0 also or must the ABI for libnl be kept as-is (counting from 1)?


--=20
=C2=A0.
=2E.: Lucian
