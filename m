From: ROUTE 66 - Catalin BOIE <cboie@route66.ro>
Subject: Re: Strange TCP dump between a Linux and a Samsung phone
Date: Wed, 12 Nov 2008 09:15:13 +0200
Message-ID: <491A8281.6040804@route66.ro>
References: <4919910E.6080700@route66.ro> <Pine.LNX.4.64.0811111701260.3930@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?77+9?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.route66.ro ([91.201.80.3]:47349 "EHLO mail.route66.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbYKLHQI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 02:16:08 -0500
In-Reply-To: <Pine.LNX.4.64.0811111701260.3930@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BF=BD wrote:
> On Tue, 11 Nov 2008, ROUTE 66 - Catalin BOIE wrote:

Hello!

After upgrading to 2.6.26.?, the problem was fixed!
Thank you very much for your super quick answer!

>> I have captured a strange dump between a Linux kernel
>> 2.6.25.6-55.fc9.x86_64 and a Samsung device.
>=20
> Please upgrade or prove that the tcp fixes that were in the later ker=
nel=20
> (.7 iirc or 2.6.26) got applied into that -55 part.
>> I looked at it and it seems that the Linux stack does not send any
>> retransmissions to Samsung device.
>> But, I want a competent look from you.
>>
>> The connection is done over a 3G connection.
>> The capture was done on a router between the two endpoints.
>> c.66.com is the Linux machine, the other IP is the Samsung device.
>=20
> ...snip...
>=20
>> As you may see, the Samsung device keeps sending an ACK for 1261841 =
and
>> after some time closes the connection.
>> Why the Linux stack does no retransmissions?
>=20
> Looks like a know bug in frto which got fixed.
>=20
> If upgrade is not an option, you can experiment by playing with tcp_f=
rto=20
> sysctl (with 0 you should not encounter that bug).

Thanks!

--=20
Catalin BOIE
ROUTE 66
