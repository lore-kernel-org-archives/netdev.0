From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 07 Oct 2014 22:54:43 +0200
Message-ID: <1412715283.11600.11.camel@localhost>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be>
	 <20141007.161832.453892039501955243.davem@davemloft.net>
	 <20141007203344.GA4748@roeck-us.net>
	 <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Di, 2014-10-07 at 22:49 +0200, Fabian Frederick wrote:
> 
> > On 07 October 2014 at 22:33 Guenter Roeck <linux@roeck-us.net> wrote:
> >
> >
> > On Tue, Oct 07, 2014 at 04:18:32PM -0400, David Miller wrote:
> > > From: Fabian Frederick <fabf@skynet.be>
> > > Date: Tue,  7 Oct 2014 22:16:36 +0200
> > >
> > > > static values are automatically initialized to NULL
> > > >
> > > > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > >
> > > Isn't there some implementation room given to compilers
> > > as to the representation of true and false?
> >
> > Not for true/false.
> >
> > C99 standard, section 7.16:
> >
> > ...
> > The remaining three macros are suitable for use in #if preprocessing
> > directives. They are
> >
> > true
> >
> > which expands to the integer constant 1,
> >
> > false
> >
> > which expands to the integer constant 0, and
> > ...
> >
> > No idea where the NULL comes into the picture, though.
> >
> > Guenter
> 
> Maybe comment should have been "static values are automatically initialized to
> 0" then ?

I think David's concern was whether if 0 == false in all situations. It
is pretty clear that static memory is initialized to 0.

Thanks,
Hannes
