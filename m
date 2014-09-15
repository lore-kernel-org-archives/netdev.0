From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: how to figure out which device a given IFB is connected to
Date: Mon, 15 Sep 2014 13:55:08 -0700
Message-ID: <20140915135508.5b346e22@urahara>
References: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de>
	<CAHA+R7NxSY8fbAMLgekAxeN4n5U_NTKUczFRz9WUcY-xSHZTxw@mail.gmail.com>
	<E5E81534-C300-42C1-B2DF-84C006A117AD@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>, netdev <netdev@vger.kernel.org>
To: Sebastian Moeller <moeller0@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:64534 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756844AbaIOUzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 16:55:12 -0400
Received: by mail-pa0-f44.google.com with SMTP id kx10so7343014pab.3
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 13:55:11 -0700 (PDT)
In-Reply-To: <E5E81534-C300-42C1-B2DF-84C006A117AD@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2014 21:06:31 +0200
Sebastian Moeller <moeller0@gmx.de> wrote:

> Hi Mr. Wang,
>=20
> Thank you for your help.
>=20
> On Sep 15, 2014, at 18:08 , Cong Wang <cwang@twopensource.com> wrote:
>=20
> > On Mon, Sep 15, 2014 at 7:37 AM, Sebastian Moeller <moeller0@gmx.de=
> wrote:
> >> I am looking for a way of doing the reverse,i.e.  figuring out for=
 a given IFB if it is =E2=80=9Cconnected=E2=80=9D to a real interface a=
nd, if yes, which interface. Basically, I want to recycle unused IFBs, =
but want to make sure that they really are unused=E2=80=A6
> >>=20
> >=20
> > There is no way to figure that out.
>=20
> 	That is rather unfortunate, so my only recourse is to get a list of =
all interfaces and query each whether it is attached to an fib and prun=
e a list of IFBs so that only the unused ones remain (which is far from=
 elegant ;) ).

It can be a many to one mapping.
There are cases where you want multiple incoming devices to all be QoS'=
d together.
