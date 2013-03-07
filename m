From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 07 Mar 2013 12:13:41 +0800
Message-ID: <513813F5.5040806@asianux.com>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz> <512F38F8.2060804@asianux.com> <512F5F14.6070801@suse.cz> <51355653.9090404@asianux.com> <5135BC3F.8070507@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:45566 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab3CGEOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 23:14:05 -0500
In-Reply-To: <5135BC3F.8070507@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 17:34, Jiri Slaby =E5=86=99=
=E9=81=93:
>>   what you said is: this patch need improving, is it correct ?
>> >   if it is correct.
>> >     I still prefer to throw the rest contents (but need improving,=
 too)
>> >       for maintaining, we need fix bug, but not need add new featu=
res
>> >       so what we should do:
>> >         a) fix the bug (should not memory overflow)
>> >         b) keep the original buffer length no touch
>> >            it is not sizeof(cmd.parm.cmsg.para) - 2)
>> >            it should be sizeof(cmd.param) - sizeof(cmd.param.cmsg)=
 + sizeof(cmd.param.cmsg.para) - 2
>> >         c) need complete the relative document to export the limit=
ation.
>> >=20
>> >   is it ok ?
> Yes, it is -- just fix the bug with minimal effort.

  ok, I will send patch v2 for it.

  :-)

--=20
Chen Gang

Asianux Corporation
