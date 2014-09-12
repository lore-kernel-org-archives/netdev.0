From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PTP_PEROUT_REQUEST and clock stepping
Date: Fri, 12 Sep 2014 08:33:10 +0200
Message-ID: <20140912063310.GA6198@netboy>
References: <54107965.6040007@emlix.com>
 <20140910172619.GB5944@localhost.localdomain>
 <20140911095245.GA5823@emlix.com>
 <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <dg@emlix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f178.google.com ([74.125.82.178]:38670 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbaILGdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 02:33:15 -0400
Received: by mail-we0-f178.google.com with SMTP id q58so236121wes.37
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 23:33:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CABkLOboeo_+37rE84gPTEKnmXD+599fRtnBZSR465y9aZeOdrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 08:24:49AM +0200, Christian Riesch wrote:
> On Thu, Sep 11, 2014 at 11:52 AM, Daniel Gl=F6ckner <dg@emlix.com> wr=
ote:
> > Only a small fraction of people
> > using periodic outputs will want to schedule the start of the signa=
l at
> > a specific time in the future and only a fraction of those will use=
 a
> > .period value that is so small that they can't use a timer to confi=
gure
> > the periodic output within .period/2 before the desired start time.
>=20
> Ok, I got it now. So you are suggesting to change the behavior of
> PTP_PEROUT_REQUEST, aren't you? And break existing applications?
> Christian

I think he wants the periodic output to continue at the same phase and
frequency, even when you reset the clock time.

However, this is impossible to acheive because the hardware does not
support it.

Thanks,
Richard
