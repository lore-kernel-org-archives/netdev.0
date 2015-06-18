From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/3 v5] iproute2: add support to print
 'linkdown' nexthop flag
Date: Thu, 18 Jun 2015 11:57:00 -0400
Message-ID: <20150618155659.GN588@gospo.home.greyhouse.net>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
 <1434640932-2681-4-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bDHTCEpqFZYYfCwc=_Wxh6-1BkGuyj04=deGHCHMC--+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:34454 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755239AbbFRP5D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 11:57:03 -0400
Received: by ykfl8 with SMTP id l8so69765882ykf.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 08:57:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bDHTCEpqFZYYfCwc=_Wxh6-1BkGuyj04=deGHCHMC--+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 08:43:08AM -0700, Scott Feldman wrote:
> On Thu, Jun 18, 2015 at 8:22 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > Signed-off-by: Andy Gospodaerk <gospo@cumulusnetworks.com>
> > Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
> >
> > ---
> >  ip/iproute.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index 3795baf..3369c49 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -451,6 +451,8 @@ int print_route(const struct sockaddr_nl *who, =
struct nlmsghdr *n, void *arg)
> >                 fprintf(fp, "offload ");
> >         if (r->rtm_flags & RTM_F_NOTIFY)
> >                 fprintf(fp, "notify ");
> > +       if (r->rtm_flags & RTNH_F_LINKDOWN)
> > +               fprintf(fp, "linkdown ");
>=20
>=20
> iproute.c: In function =E2=80=98print_route=E2=80=99:
> iproute.c:454:21: error: =E2=80=98RTNH_F_LINKDOWN=E2=80=99 undeclared=
 (first use in
> this function)
> iproute.c:454:21: note: each undeclared identifier is reported only
> once for each function it appears in

Yes, you need to pull that from the patches above into your iproute2
sources.  Stephen regularly tells people not to pose uapi updates, so I
did not.
