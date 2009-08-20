From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 14:18:20 +0200
Message-ID: <20090820121820.GA21354@uio.no>
References: <20090820111152.GA20295@uio.no>
 <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:60121 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbZHTMSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 08:18:21 -0400
Content-Disposition: inline
In-Reply-To: <7d4abbaea1f1e17050a0e8ffe4917cb8@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 01:29:09PM +0200, R=C3=A9mi Denis-Courmont wrot=
e:
>> I've tried attaching a type-0 routing header to my IPv6 packets with
>> setsockopt(..., IPV6_RTHDR, ...), but the kernel just returns EINVAL=
=2E
>> looking at the source, it seems it simply refuses anything that's no=
t
>> type-2;
>> should that really be right? I found the following commit:
> RT0 headers have been deprecated by IETF. The kernel refuses to use t=
hen on
> purpose.

Hm, OK. And no replacement has been proposed, the deprecation RFC just =
refers
to "future routing headers"...

/* Steinar */
--=20
Homepage: http://www.sesse.net/
