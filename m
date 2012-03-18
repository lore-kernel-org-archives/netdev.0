From: yao zhao <yao.development@gmail.com>
Subject: Re: setns question
Date: Sat, 17 Mar 2012 22:16:33 -0400
Message-ID: <CADDf=MR9e8rRF-bebju2uw0JijkqKepWmjrOvSKvW0OT=C0EDg@mail.gmail.com>
References: <CADDf=MSHZUeq8V9jx9ybofCu9m=_L2vYaNRhFEd9EL0AVi5O4w@mail.gmail.com>
	<m1aa3g86ev.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42038 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab2CRCQe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 22:16:34 -0400
Received: by iagz16 with SMTP id z16so7574001iag.19
        for <netdev@vger.kernel.org>; Sat, 17 Mar 2012 19:16:34 -0700 (PDT)
In-Reply-To: <m1aa3g86ev.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 16, 2012 at 7:36 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> yao zhao <yao.development@gmail.com> writes:
>
>> Hi Eric,
>>
>> Can I ask some questions about setns?
>>
>> 1.setns is complete > 3.0 but right now it doesn't support mnt and p=
id
>> yet.
>
> Correct. =A0I need to find some time and get those patches merged.
>
>> 2.setns can set a process' uts, net, ipc to different namespace,
>
> Yes.
>> it is not fd based, right?
> The argument to setns is a fd.
>
>> 3.is this supported:
>> =A0 =A0 =A0ProcessA's uts =3D=3D ProcessB's uts
>> =A0 =A0 =A0ProcessA's ipc =3D=3D ProcessC's ipc
>> =A0 =A0 =A0ProcessA's net =3D=3D ProcessD's net
>
> Yes. =A0Even without setns that is supported.
>
> I suggest if you want more details you read the code.
>
Thanks Eric for your reply!
After 1 day source code reading I understood how network namespace is
implemented. It is excellent and it does what I need.

yao
> Eric
