From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] drivers/isdn/divert: break looping, or memory leak
 by calling kmalloc again
Date: Mon, 01 Apr 2013 18:19:56 +0800
Message-ID: <51595F4C.3040107@asianux.com>
References: <5158ECBD.4050109@asianux.com> <51595C9A.1060608@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, Jiri Slaby <jslaby@suse.cz>,
	Jiri Kosina <jkosina@suse.cz>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:48669 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056Ab3DAKU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 06:20:29 -0400
In-Reply-To: <51595C9A.1060608@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8801=E6=97=A5 18:08, Tilman Schmidt wrote:
> Am 01.04.2013 04:11, schrieb Chen Gang:
>> > in drivers/isdn/divert/isdn_divert.c:
>> >=20
>> >   in 'for' looping (line 395..515)
>> >     the 'cs' may call kmalloc again (line 453).
>> >=20
>> >   it seems need break looping, when get valid 'cs' value (line 509=
)
> I don't think so. If the kmalloc for cs succeeds, control flow will
> continue linearly up to the 'if' statement in line 503. Then it will
> either kfree(cs) and return, or reach the 'break' in line 514 which
> will end the 'for' loop.

  oh, really it is, it is my fault !
    (I did not see the break at line 514)

  thanks.

  :-)



--=20
Chen Gang

Asianux Corporation
