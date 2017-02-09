From: Denny Page <dennypage@me.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Thu, 09 Feb 2017 12:37:38 -0800
Message-ID: <BEB8365E-2031-4FD0-8976-2ACFE6B5641C@me.com>
References: <20170207140144.GA11233@localhost>
 <20170209080242.GA1698@localhost.localdomain>
 <20170209110941.GA1449@localhost>
 <CAHoNx5_S3dCSbqfHT+i=VMqw11PcEMA2bBY8Sbp=pAFAhBL6CA@mail.gmail.com>
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
Received: from st11p06im-asmtp002.me.com ([17.172.125.150]:35579 "EHLO
        st11p06im-asmtp002.me.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753362AbdBIUiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 15:38:00 -0500
Received: from process-dkim-sign-daemon.st11p06im-asmtp002.me.com by
 st11p06im-asmtp002.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OL400800JXLRA00@st11p06im-asmtp002.me.com> for netdev@vger.kernel.org;
 Thu, 09 Feb 2017 20:37:42 +0000 (GMT)
In-reply-to: <CAHoNx5_S3dCSbqfHT+i=VMqw11PcEMA2bBY8Sbp=pAFAhBL6CA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 09, 2017, at 11:42, sdncurious <sdncurious@gmail.com> wrote:
>=20
> As you are using HW that supports NTP time stamping won't it by
> default time stamp the receiving packet correctly at the CRC ? Or if
> someone came out with such a HW than what ?

As discussed in private email, all hardware operates at the end of the =
SFD, and in makes sense for the hardware to always do so regardless of =
what protocol is passing through.

Denny
