From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: checkentry function
Date: Tue, 05 Oct 2010 08:23:58 +0200
Message-ID: <1286259838.2457.11.camel@edumazet-laptop>
References: <AANLkTimeoRTBMY0OH5sDtVEfqFCx9F3go1qGKy5cJpWS@mail.gmail.com>
	 <20101005144615.0f84d53a@s6510>
	 <AANLkTikDi3ziyH9eJbEhjOBwjFVHrtsMzYEJes4=eiJF@mail.gmail.com>
	 <20101005150147.62226282@s6510>
	 <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38486 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757565Ab0JEGYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 02:24:04 -0400
In-Reply-To: <AANLkTinTd5FjJ-6WeAGwintAS9aHdFYnS7--TLMSDEkn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 octobre 2010 =C3=A0 08:11 +0200, Nicola Padovano a =C3=A9cr=
it :
> >
> > Negative (ie < 0) is used for error numbers. This is confusing
> > because in older kernels the checkentry returned a bool which
> > is defined as 1 okay and 0 for error.
> >
> ok i see.
>=20
> and why i have this output?
> DEBUG: the tablename (not FILTER) is: =EF=BF=BD%H =EF=BF=BD
>=20
> I want block my target if the table name is NOT filter...so i write:
>=20
> [CODE]
> ...
>  if (strcmp(tablename, "filter"))   {
>    printk(KERN_INFO "DEBUG: the tablename (not FILTER) is %s\n",table=
name);
>    return ERROR_VALUE; // < 0
>  }
> [/CODE]
>=20
> but in the tablename variable i haven't the table's right value (but =
i
> have: =EF=BF=BD%H =EF=BF=BD a wrong value)...what's the problem?
>=20
>=20

Because xxx_check() signature is not the one you use.

Could you read source code of _current_ existing modules , and use
copy/paste ?

static int hashlimit_mt_check(const struct xt_mtchk_param *par)
{
=2E..
}



