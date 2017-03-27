From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 14:20:12 -0700
Message-ID: <0396ABE8-ECF6-49F1-A7B9-7E1224E37B66@me.com>
References: <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
 <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com> <20170327182828.GA2254@netboy>
 <48C4929F-680A-4F8F-8CE8-7DF3A3E5D83E@me.com>
 <20170327205807.GA11139@localhost.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:40560 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbdC0VUS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 17:20:18 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONH00W00SGVGE00@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Mon, 27 Mar 2017 21:20:16 +0000 (GMT)
In-reply-to: <20170327205807.GA11139@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 27, 2017, at 13:58, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> On Mon, Mar 27, 2017 at 12:18:47PM -0700, Denny Page wrote:
>> I think that on average, the Vendor=E2=80=99s numbers are likely to =
be more
>> accurate than anyone else=E2=80=99s. The concept that independent =
software
>> implementations are going to somehow obtain and maintain better
>> numbers is too much of a stretch.
>=20
> But you just said that Intel's first published numbers were wrong.  If
> the vendors would have published accurate information, then you would
> not have to have made your own measurements, and the drivers could
> simply use the correct values.
>=20
> Sadly, this will never happen.  The vendor's track record is 100%
> fail.  The apps will always need to implement their own, truly correct
> values.  Having "almost correct" values hard coded into the drivers
> only makes things worse.

Yes, Intel=E2=80=99s original numbers were wrong. But that doesn=E2=80=99t=
 mean that other=E2=80=99s people=E2=80=99s numbers are going to be =
particularly better. Even Intel=E2=80=99s original numbers were far =
better than most will be able to achieve.=20

But let=E2=80=99s bring this back to the driver. If someone conducts =
tests and believes that they have better numbers than currently used in =
the driver, let them come forward with their information and propose a =
kernel patch. No harm in that at all. And much easier than brining a =
patch for dozens of applications.

Denny
