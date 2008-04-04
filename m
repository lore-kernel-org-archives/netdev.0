From: Georgi Chorbadzhiyski <gf@unixsol.org>
Subject: Re: Linux 2.6.25-rc6: WARNING: at net/ipv4/tcp_input.c:2510
Date: Fri, 04 Apr 2008 09:16:49 +0300
Message-ID: <47F5C7D1.1080906@unixsol.org>
References: <47EBCB75.6030600@unixsol.org> <Pine.LNX.4.64.0804031315360.21524@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.unixsol.org ([193.110.159.2]:44169 "EHLO ns.unixsol.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbYDDGQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 02:16:50 -0400
In-Reply-To: <Pine.LNX.4.64.0804031315360.21524@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Around 04/03/08 13:17, Ilpo J=E4rvinen scribbled:
> On Thu, 27 Mar 2008, Georgi Chorbadzhiyski wrote:
>=20
>> A week ago I updated one of my servers to 2.6.25-rc6 and today looki=
ng
>> through logs I've found these:
>>
>> [380219.823434] ------------[ cut here ]------------
>> [380219.823450] WARNING: at net/ipv4/tcp_input.c:2510 tcp_ack+0xc7e/=
0x177d()
>=20
> Is this reproducable for you? If yes, is it possible for you to run=20

Not in the moment.

I'm not getting such errors in the log since my last report. Today I'll=
 update
to latest -git and will restart the server.

The machine that gave me this error is a http and ftp server handling n=
ot
very busy distro mirror (if this can give you any clues).

> processing expensive verification of TCP state (validates TCP write q=
ueue=20
> invariants multiple times per ACK by scanning through the write queue=
) on=20
> such machine?

How to run such a thing, can you give me some pointers?

--=20
Georgi Chorbadzhiyski
http://georgi.unixsol.org/
