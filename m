From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2] socket.7: Document some BPF-related socket options
Date: Tue, 1 Mar 2016 11:29:56 +0100
Message-ID: <56D56F24.3090605@gmail.com>
References: <1456767399-7533-1-git-send-email-kraigatgoog@gmail.com>
 <56D56901.5070307@gmail.com> <87k2lm7bks.fsf@zoro.exoscale.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mtk.manpages@gmail.com, Craig Gallek <kraigatgoog@gmail.com>,
	linux-man@vger.kernel.org, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33106 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbcCAKaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 05:30:03 -0500
In-Reply-To: <87k2lm7bks.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2016 11:10 AM, Vincent Bernat wrote:
>  =E2=9D=A6  1 mars 2016 11:03 +0100, "Michael Kerrisk (man-pages)" <m=
tk.manpages@gmail.com> :
>=20
>>           Once   the   SO_LOCK_FILTER  option  has  been  enabled,
>>           attempts by an unprivileged process to change or  remove
>>           the  filter  attached  to  a  socket,  or to disable the
>>           SO_LOCK_FILTER option will fail with the error EPERM.
>=20
> You should remove "unprivileged". I didn't try to check for permissio=
ns
> because I was just lazy (and I didn't have a need for it). As root, y=
ou
> can just recreate another socket.

Bother. That's what I meant to do, and then I omitted to do it! Done no=
w
And thanks for catching that, Vincent.

Revised text below, with another query.

       SO_LOCK_FILTER
              When set, this option will prevent changing the  filters
              associated  with  the socket.  These filters include any
              set   using   the   socket   options   SO_ATTACH_FILTER,
              SO_ATTACH_BPF,        SO_ATTACH_REUSEPORT_CBPF       and
              SO_ATTACH_REUSEPORT_EPBF.

              The typical use case is for a privileged process to  set
              up  a  socket with restrictive filters, set SO_LOCK_FIL=E2=
=80=90
              TER, and then either drop its  privileges  or  pass  the
              socket file descriptor to an unprivileged process.

              Once   the   SO_LOCK_FILTER  option  has  been  enabled,
              attempts to change or remove the filter  attached  to  a
              socket,  or  to  disable  the SO_LOCK_FILTER option will
              fail with the error EPERM.

I think the second paragraph should probably drop mention of privileges=
,
right? In fact, maybe just drop the paragraph altogether?

Cheers,

Michael
=20


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
