From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Mar 2017 12:18:47 -0700
Message-ID: <48C4929F-680A-4F8F-8CE8-7DF3A3E5D83E@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost> <20170323162145.GB8192@localhost>
 <6121D504-288F-4C9B-9AB3-D1C8292965D5@me.com>
 <20170324094530.GE8192@localhost>
 <89CFCD8E-1A58-48C5-9D6E-99695502CFD9@me.com>
 <20170327101324.GI8192@localhost>
 <20170327142925.GA13305@localhost.localdomain>
 <6DE3E5F4-E69F-4334-9012-FD273ACA3C5B@me.com> <20170327182828.GA2254@netboy>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>, netdev@vger.kernel.org,
        Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:35479 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751828AbdC0TTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 15:19:02 -0400
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0ONH00300MXTQ700@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Mon, 27 Mar 2017 19:18:51 +0000 (GMT)
In-reply-to: <20170327182828.GA2254@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Mar 27, 2017, at 11:28, Richard Cochran <richardcochran@gmail.com> =
wrote:
>=20
> On Mon, Mar 27, 2017 at 09:25:03AM -0700, Denny Page wrote:
>=20
>> I agree that the values in the igb driver are incorrect. They were
>> middle of the range values from the old tables. At least for 100Mb,
>> Intel seems to know that the original table was incorrect. I=E2=80=99ve=
 done
>> extensive measurements of the i210 and i211 at both 100Mb and
>> 1Gb. The =E2=80=9Cexternal link partner=E2=80=9D numbers Intel =
currently publishes
>> for the 100Mb appear accurate.
>=20
> Well, after reading this, I am more convinced than ever that doing the
> correction in user space is the right way.  If the one and only vendor
> who publishes numbers can't even get them straight, how on earth will
> we ever get the drivers right?

I think that on average, the Vendor=E2=80=99s numbers are likely to be =
more accurate than anyone else=E2=80=99s. The concept that independent =
software implementations are going to somehow obtain and maintain better =
numbers is too much of a stretch.

FWIW, My testing indicates that the 100Mb numbers that Intel currently =
publishes are quite accurate. I don=E2=80=99t believe that Intel did the =
driver corrections btw, if memory serves these values were lifted from =
the Mac.

Denny
