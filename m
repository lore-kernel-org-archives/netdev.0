From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 7 Oct 2014 23:05:05 +0200 (CEST)
Message-ID: <512814057.20732.1412715905370.open-xchange@webmail.nmp.skynet.be>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be> <20141007.161832.453892039501955243.davem@davemloft.net> <20141007203344.GA4748@roeck-us.net> <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be> <1412715283.11600.11.camel@localhost>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>,
	David Miller <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412715283.11600.11.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 07 October 2014 at 22:54 Hannes Frederic Sowa <hannes@stressindukt=
ion.org>
> wrote:
>
>
> On Di, 2014-10-07 at 22:49 +0200, Fabian Frederick wrote:
> >
> > > On 07 October 2014 at 22:33 Guenter Roeck <linux@roeck-us.net> wr=
ote:
> > >
> > >
> > > On Tue, Oct 07, 2014 at 04:18:32PM -0400, David Miller wrote:
> > > > From: Fabian Frederick <fabf@skynet.be>
> > > > Date: Tue,=C2=A0 7 Oct 2014 22:16:36 +0200
> > > >
> > > > > static values are automatically initialized to NULL
> > > > >
> > > > > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > > >
> > > > Isn't there some implementation room given to compilers
> > > > as to the representation of true and false?
> > >
> > > Not for true/false.
> > >
> > > C99 standard, section 7.16:
> > >
> > > ...
> > > The remaining three macros are suitable for use in #if preprocess=
ing
> > > directives. They are
> > >
> > > true
> > >
> > > which expands to the integer constant 1,
> > >
> > > false
> > >
> > > which expands to the integer constant 0, and
> > > ...
> > >
> > > No idea where the NULL comes into the picture, though.
> > >
> > > Guenter
> >
> > Maybe comment should have been "static values are automatically ini=
tialized
> > to
> > 0" then ?
>
> I think David's concern was whether if 0 =3D=3D false in all situatio=
ns. It
> is pretty clear that static memory is initialized to 0.
>
> Thanks,
> Hannes

Of course :) It was an answer to Guenter's explanation.

Regards,
=46abian
>
>
