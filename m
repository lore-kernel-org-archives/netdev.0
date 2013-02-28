From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 28 Feb 2013 14:43:48 +0100
Message-ID: <512F5F14.6070801@suse.cz>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz> <512F38F8.2060804@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:50934 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab3B1Nnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 08:43:53 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so1528024eek.13
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 05:43:51 -0800 (PST)
In-Reply-To: <512F38F8.2060804@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 12:01 PM, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 18:00, Jiri Slaby =E5=86=
=99=E9=81=93:
>> I don't think there are piles of people to care about ISDN much nowa=
days.=20
>=20
>   I don't think either.
>     (I found it through reading the source code, by search strncpy)
>=20
>   if this is quite minor:
>     I suggest to delete this module.

Nah, there *are* still people using ISDN.

>> So we can
>> close that it is correct to drop the rest of the buffer. In a hope t=
hat
>> +M is not followed by text longer than 50-or-so chars.
>=20
>   can we be sure that "+M..." is no more than 100+ chars ?
>     (I guess the sizeof (isdn_ctrl.parm) is 80+, but less than 100)
>   if we can not be sure:

No, we cannot be sure that a user gives us less than that. Your patch
just throws the rest to fix that overflow, right? What I'm saying I
wouldn't fix more than that.

--=20
js
suse labs
