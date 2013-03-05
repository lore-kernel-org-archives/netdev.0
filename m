From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Tue, 05 Mar 2013 10:20:03 +0800
Message-ID: <51355653.9090404@asianux.com>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz> <512F38F8.2060804@asianux.com> <512F5F14.6070801@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:55923 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932595Ab3CECU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:20:26 -0500
In-Reply-To: <512F5F14.6070801@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 21:43, Jiri Slaby =E5=86=99=
=E9=81=93:
>=20
> Nah, there *are* still people using ISDN.
>=20

  ok, thanks.

  it seems, we need maintaining ISDN:
    need fix bugs.
    need not add new features.
    need keep current features no touch.


> No, we cannot be sure that a user gives us less than that. Your patch
> just throws the rest to fix that overflow, right? What I'm saying I
> wouldn't fix more than that.

  what you said is: this patch need improving, is it correct ?
  if it is correct.
    I still prefer to throw the rest contents (but need improving, too)
      for maintaining, we need fix bug, but not need add new features
      so what we should do:
        a) fix the bug (should not memory overflow)
        b) keep the original buffer length no touch
           it is not sizeof(cmd.parm.cmsg.para) - 2)
           it should be sizeof(cmd.param) - sizeof(cmd.param.cmsg) + si=
zeof(cmd.param.cmsg.para) - 2
        c) need complete the relative document to export the limitation=
=2E

  is it ok ?
    (if it is not ok, welcome to provide suggestion or completion)


  thanks.

  :-)

--=20
Chen Gang

Asianux Corporation
