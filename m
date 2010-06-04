From: Satoru SATOH <satoru.satoh@gmail.com>
Subject: Re: 200 millisecond timeouts in TCP
Date: Sat, 5 Jun 2010 00:02:02 +0900
Message-ID: <20100604150202.GA8268@localhost.localdomain>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com> <AANLkTilsYS8P2VqATmasXjjdhjPMMZznIHBByXc1i8cU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Novick <novickivan@gmail.com>, netdev@vger.kernel.org
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:62625 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354Ab0FDPCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 11:02:09 -0400
Received: by pwj5 with SMTP id 5so27504pwj.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 08:02:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <AANLkTilsYS8P2VqATmasXjjdhjPMMZznIHBByXc1i8cU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible to tune the RTO min value (rto_min) per route since
2.6.23+.  (see also the manual of iproute2, ip(8) )

- satoru

On Fri, Jun 04, 2010 at 03:58:57PM +0900, Ryousei Takano wrote:
> On Fri, Jun 4, 2010 at 7:37 AM, Ivan Novick <novickivan@gmail.com> wr=
ote:
> > Hello,
> >
> > Using tcpdump and systemtap I am seeing that sometimes retransmissi=
on
> > of data is sent after waiting 200 milliseconds. =C2=A0However somet=
imes
> > retransmissions happen quicker.
> >
> > Is there a specifc event that causes these 200 milisec delays to ki=
ck
> > in? =C2=A0Are those events identifiable in netstat -s output?
> >
> > Also do you know if the timeout numbers for TCP are configurable pa=
rameters?
> >
> The minimum RTO value is fixed to 200 ms.  It is useful to make the m=
in/max
> RTO values tunable.  For example, reducing the minimum RTO value is e=
ffective
> for TCP incast problem [1].  Of course, it may occur spurious retrans=
missions.
>=20
> [1] Vijay Vasudevan, et al, Safe and Effective Fine-grained TCP Retra=
nsmissions
> for Datacenter Communication, SIGCOMM2009
>=20
> In Solaris, there are two tunable parameters: tcp_rexmit_interval_min=
/max.
>=20
> Do you have plan to introduce sysctl parameters like these to the Lin=
ux.
>=20
> Thanks,
> Ryousei
