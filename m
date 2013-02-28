From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 28 Feb 2013 19:01:12 +0800
Message-ID: <512F38F8.2060804@asianux.com>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz> <512EB6CA.6030609@asianux.com> <512F2AA7.4040204@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:24231 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060Ab3B1LBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 06:01:32 -0500
In-Reply-To: <512F2AA7.4040204@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8828=E6=97=A5 18:00, Jiri Slaby =E5=86=99=
=E9=81=93:
> I don't think there are piles of people to care about ISDN much nowad=
ays.=20

  I don't think either.
    (I found it through reading the source code, by search strncpy)

  if this is quite minor:
    I suggest to delete this module.
    the reason is:
      it can not provide contributes, any more.
      but may give a chance to the hacker which want to make an attack.

  :-)

> So we can
> close that it is correct to drop the rest of the buffer. In a hope th=
at
> +M is not followed by text longer than 50-or-so chars.

  can we be sure that "+M..." is no more than 100+ chars ?
    (I guess the sizeof (isdn_ctrl.parm) is 80+, but less than 100)
  if we can not be sure:
    do we need check and limit the length ? (I prefer to give a check)
    if the module will really be delete,
      I still suggest to maintain previous versions (for security issue=
)


  thanks.


--=20
Chen Gang

Asianux Corporation
