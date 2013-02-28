From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 28 Feb 2013 11:00:07 +0100
Message-ID: <512F2AA7.4040204@suse.cz>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:48128 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163Ab3B1KAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 05:00:11 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1312064eei.35
        for <netdev@vger.kernel.org>; Thu, 28 Feb 2013 02:00:10 -0800 (PST)
In-Reply-To: <512EB6CA.6030609@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 02:45 AM, Chen Gang wrote:
> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 18:44, Jiri Slaby =E5=86=
=99=E9=81=93:
>> On 02/27/2013 11:25 AM, Chen Gang wrote:
>>>> =E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 17:48, Jiri Slaby =E5=
=86=99=E9=81=93:
>>>>>> I have no idea if
>>>>>> this is correct from the ISDN POV as we drop the end of the buff=
er
>>>>
>>>>   pardon ?  what about "ISDN POV".
>> "point of view" aka POV.
>>
>> Hmm, "also known as" alias "aka" :).
>=20
>=20
>   sorry, I still not quite understand (I am really not familiar with =
ISDN)
>=20
>   so I have to bother you with 2 questions, please help reply, thanks=
=2E
>=20
>     A) is our current patch OK ?
>        a. yes, ok, need do nothing for it, just is waiting for Acked-=
by or applying.
>        b. no, need improving (e.g. additional consideration, comments=
, or others)
>        c. no, it is useless patch.
>=20
>     B) does "ISDN POV" point to another issue ?
>        if yes:
>          I will read source code or search document on net, and shoul=
d not bother you again.
>          if possible, I can try to send relative patches, next.
>        else (no):
>          could you please say more details again ?

No, the sentence was "I have no idea if this is correct from the ISDN
point of view because we drop the end of the buffer." I don't think
there are piles of people to care about ISDN much nowadays. So we can
close that it is correct to drop the rest of the buffer. In a hope that
+M is not followed by text longer than 50-or-so chars.

There is nothing more to fix. (Well, there is, but not in this context.=
)

--=20
js
suse labs
