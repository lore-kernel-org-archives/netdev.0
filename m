From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Tue, 05 Mar 2013 10:34:55 +0100
Message-ID: <5135BC3F.8070507@suse.cz>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz> <512F38F8.2060804@asianux.com> <512F5F14.6070801@suse.cz> <51355653.9090404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:63180 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148Ab3CEJfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 04:35:00 -0500
Received: by mail-ee0-f41.google.com with SMTP id c13so4640677eek.0
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 01:34:58 -0800 (PST)
In-Reply-To: <51355653.9090404@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2013 03:20 AM, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 21:43, Jiri Slaby =E5=86=
=99=E9=81=93:
>>
>> Nah, there *are* still people using ISDN.
>>
>=20
>   ok, thanks.
>=20
>   it seems, we need maintaining ISDN:
>     need fix bugs.
>     need not add new features.
>     need keep current features no touch.
>=20
>=20
>> No, we cannot be sure that a user gives us less than that. Your patc=
h
>> just throws the rest to fix that overflow, right? What I'm saying I
>> wouldn't fix more than that.
>=20
>   what you said is: this patch need improving, is it correct ?
>   if it is correct.
>     I still prefer to throw the rest contents (but need improving, to=
o)
>       for maintaining, we need fix bug, but not need add new features
>       so what we should do:
>         a) fix the bug (should not memory overflow)
>         b) keep the original buffer length no touch
>            it is not sizeof(cmd.parm.cmsg.para) - 2)
>            it should be sizeof(cmd.param) - sizeof(cmd.param.cmsg) + =
sizeof(cmd.param.cmsg.para) - 2
>         c) need complete the relative document to export the limitati=
on.
>=20
>   is it ok ?

Yes, it is -- just fix the bug with minimal effort.

--=20
js
suse labs
