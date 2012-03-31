From: Ulrich Drepper <drepper@gmail.com>
Subject: Re: sendmmsg: put_user vs __put_user
Date: Sat, 31 Mar 2012 08:30:25 -0400
Message-ID: <CAOPLpQewA-AduBudgH5FK6Kz_=nHv6eFhGD29TkAosPTdP4ZHg@mail.gmail.com>
References: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
 <20120330.205120.2221145622131588797.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43005 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671Ab2CaMaq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 08:30:46 -0400
In-Reply-To: <20120330.205120.2221145622131588797.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 30, 2012 at 20:51, David Miller <davem@davemloft.net> wrote=
:
> Compat processes are not able to generate virtual addresses anywhere
> near the range where the kernel resides, so the address range
> verification done by put_user() is completely superfluous and
> therefore not necessary. =C2=A0The normal exception handling done by =
the
> access is completely sufficient.

I was more thinking about the effects of might_fault() then additional =
tests.
