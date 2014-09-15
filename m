From: Sebastian Moeller <moeller0@gmx.de>
Subject: Re: how to figure out which device a given IFB is connected to
Date: Mon, 15 Sep 2014 21:06:31 +0200
Message-ID: <E5E81534-C300-42C1-B2DF-84C006A117AD@gmx.de>
References: <CBDE840F-96BA-4839-9774-86F72E99E964@gmx.de> <CAHA+R7NxSY8fbAMLgekAxeN4n5U_NTKUczFRz9WUcY-xSHZTxw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:65463 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754475AbaIOTGe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:06:34 -0400
In-Reply-To: <CAHA+R7NxSY8fbAMLgekAxeN4n5U_NTKUczFRz9WUcY-xSHZTxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mr. Wang,

Thank you for your help.

On Sep 15, 2014, at 18:08 , Cong Wang <cwang@twopensource.com> wrote:

> On Mon, Sep 15, 2014 at 7:37 AM, Sebastian Moeller <moeller0@gmx.de> =
wrote:
>> I am looking for a way of doing the reverse,i.e.  figuring out for a=
 given IFB if it is =93connected=94 to a real interface and, if yes, wh=
ich interface. Basically, I want to recycle unused IFBs, but want to ma=
ke sure that they really are unused=85
>>=20
>=20
> There is no way to figure that out.

	That is rather unfortunate, so my only recourse is to get a list of al=
l interfaces and query each whether it is attached to an fib and prune =
a list of IFBs so that only the unused ones remain (which is far from e=
legant ;) ).

Best Regards
	Sebastian Moeller