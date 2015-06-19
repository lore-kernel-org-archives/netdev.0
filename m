From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net 0/2] bridge: multicast behaviour fixes
Date: Fri, 19 Jun 2015 11:45:19 +0300
Message-ID: <22203C5F-C5FF-439A-96A0-CE7F84C7D147@cumulusnetworks.com>
References: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stephen@networkplumber.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, sashok@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35320 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbbFSIpV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 04:45:21 -0400
Received: by wiga1 with SMTP id a1so12240744wig.0
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 01:45:20 -0700 (PDT)
In-Reply-To: <1434540511-648-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 17, 2015, at 2:28 PM, Nikolay Aleksandrov <nikolay@cumulusnetw=
orks.com> wrote:
>=20
> Hi,
> Patch 01 fixes a problem when a router is configured and a port goes
> through a link down/up, the router configuration was not restored.
> Patch 02 starts the multicast querier when using user-space STP and a
> port goes to forwarding state.
> These are behaviour fixes and if you think they are more appropriate =
for
> net-next, then feel free to apply them there, I've run them with both
> net and net-next. Also I've provided "fixes" tags, but since these ar=
e
> behaviour changes they're the initial implementations of these functi=
ons.
>=20
> Best regards,
> Nikolay Aleksandrov
>=20
> Satish Ashok (2):
>  bridge: multicast: restore router configuration on port link down/up
>  bridge: multicast: start querier timer when running user-space stp
>=20
> net/bridge/br_multicast.c | 4 ++++
> net/bridge/br_stp.c       | 3 +++
> 2 files changed, 7 insertions(+)
>=20
> --=20
> 2.4.3
>=20

Dave please drop this series, I=E2=80=99ll post the patches separately =
because I have
to implement Herbert=E2=80=99s suggestion and would like to repurpose p=
atch 02 for
net-next.

Thanks,
 Nik