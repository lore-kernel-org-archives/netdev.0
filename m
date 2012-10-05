From: Jiri Slaby <jslaby@suse.cz>
Subject: 3.6: net circualr lockind dependence [was: 3.5 stable somewhere ?]
Date: Fri, 05 Oct 2012 10:05:50 +0200
Message-ID: <506E94DE.6040507@suse.cz>
References: <506DDFAC.5010900@opensuse.org> <506DEB58.5030707@suse.cz> <506E2369.4050908@opensuse.org> <506E2E50.3080205@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: opensuse-kernel@opensuse.org, ML netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?Q3Jpc3RpYW4gUm9kcsOtZ3Vleg==?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:45214 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab2JEIFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 04:05:54 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so264335wib.1
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 01:05:52 -0700 (PDT)
In-Reply-To: <506E2E50.3080205@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding netdev. (Cristian is seeing a circular locking dependence in 3.6=
=2E)

On 10/05/2012 02:48 AM, Cristian Rodr=C3=ADguez wrote:
> El jue 04 oct 2012 21:01:45 CLST, Cristian Rodr=C3=ADguez escribi=C3=B3=
:
>> El 04/10/12 17:02, Jiri Slaby escribi=C3=B3:
>>> On 10/04/2012 09:12 PM, Cristian Rodr=C3=ADguez wrote:
>>>> BTW.. here is the crash.. is just a matter of generating a little
>>>> load on apache2-event and something goes crazy.
>>>
>>> Is there a fix known? The traces below look pretty hopeless. Are th=
ey
>>> the first info printed? What's before them?
>>>
>>
>> Do You have any hints how to proceed here ? I have both compiled cus=
tom
>> kernels and used SUSE packages plus
>>
>> kernel.softlockup_panic =3D 1
>> kernel.unknown_nmi_panic =3D 1
>> kernel.panic_on_unrecovered_nmi =3D 1
>> vm.panic_on_oom =3D 1
>>
>>
>> and kdump in order to get a workable backtrace, with no avail, machi=
ne
>> hangs and the kernel dump is never written.
>=20
>=20
> With a debug kernel I get this at shutdown, but I am not sure it is=20
> related at all.

Uploaded here:
http://www.fi.muni.cz/~xslaby/sklad/panics/lockdep1.png

--=20
js
suse labs
