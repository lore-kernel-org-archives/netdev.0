From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Fri, 10 Feb 2017 10:55:35 -0800
Message-ID: <97185563-83FD-46D6-B8CE-D3F236157D4D@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <CAHoNx5_S3dCSbqfHT+i=VMqw11PcEMA2bBY8Sbp=pAFAhBL6CA@mail.gmail.com>
 <CB10D113-C345-45FD-8B87-F8E08350E818@me.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        Richard Cochran <richardcochran@gmail.com>,
        netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@redhat.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Willem de Bruijn <willemb@google.com>
To: sdncurious <sdncurious@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from st11p06im-asmtp001.me.com ([17.172.125.149]:55434 "EHLO
        st11p06im-asmtp001.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdBJS4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:56:24 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp001.me.com by
 st11p06im-asmtp001.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL6010009VOC900@st11p06im-asmtp001.me.com> for netdev@vger.kernel.org;
 Fri, 10 Feb 2017 18:55:39 +0000 (GMT)
In-reply-to: <CB10D113-C345-45FD-8B87-F8E08350E818@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 09, 2017, at 16:33, Denny Page <dennypage@me.com> wrote:
>=20
>=20
>> On Feb 09, 2017, at 11:42, sdncurious <sdncurious@gmail.com> wrote:
>>=20
>> I am still at a loss as to why transpose is required in case of HW
>> time stamping. If STF is used for both Tx and Rx time stamping the
>> timing is absolutely correct.
>=20
> Perhaps this will help. The specific transposition is:
>=20
>  transposed_timestamp_ns =3D timestamp_ns + (frame_len_bits * =
1000000000) / (interface_speed * 1000000)
>=20
> The transposition is applied to received timestamps only.


Before anyone else asks, yes, I know this can be reduced. :)=
