From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Mon, 11 Oct 2010 11:14:32 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1010111114180.11247@router.home>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>  <20101008145256.GB10393@redhat.com>  <1286550247.2959.444.camel@edumazet-laptop>  <alpine.DEB.2.00.1010111102390.11247@router.home> <1286813237.2737.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1728036562-1286813673=:11247"
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:21394 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754641Ab0JKQOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:14:35 -0400
In-Reply-To: <1286813237.2737.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1728036562-1286813673=:11247
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 11 Oct 2010, Eric Dumazet wrote:

> Le lundi 11 octobre 2010 =C3=A0 11:03 -0500, Christoph Lameter a =C3=A9cr=
it :
> > On Fri, 8 Oct 2010, Eric Dumazet wrote:
> >
> > > 8 in the <pagesperslab> column just says that : order-3 pages, even f=
or
> > > small allocations.
> >
> > Those allocations will fallback to smaller allocs if the page allocator
> > has trouble satisfying those requests.
> >
>
> Interesting, do you have an idea when this feature was added ?

A couple of years ago.

---1463811839-1728036562-1286813673=:11247--
