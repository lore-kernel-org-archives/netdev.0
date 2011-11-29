From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 09:43:54 +0100
Message-ID: <1322556234.2970.84.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	 <CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	 <1322550138.2970.70.camel@edumazet-laptop> <4ED4885F.8060309@intel.com>
	 <CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36758 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604Ab1K2IoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 03:44:00 -0500
Received: by faaq16 with SMTP id q16so26011faa.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 00:43:59 -0800 (PST)
In-Reply-To: <CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 09:37 +0100, Dave Taht a =C3=A9crit :
> On Tue, Nov 29, 2011 at 8:23 AM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
> >
> > I wonder if we should consider enabling TSO/GSO per queue or per tr=
affic
> > class on devices that support this. At least in devices that suppor=
t
> > multiple traffic classes it seems to be a common usage case to put =
bulk
> > storage traffic (iSCSI) on a traffic class and low latency traffic =
on a
> > separate traffic class, VoIP for example.
>=20
>=20
> VOIP is a drop in the bucket.
>=20
> Turning TSO off on TCP exiting the datacenter (or more specifically),
> destined anywhere there is potential tx/rx bandwidth disparity
> would be goooooood.
>=20

If your cpu is fast enough (and they are most of the time), this makes
no difference at all.

Instead of consuming 3% of cpu with TSO, you'll consume 10% or 15% and
no difference seen on the wire.

Really, if you want to avoid bursts, TSO has litle to do with them.
