From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 7 Oct 2014 22:49:31 +0200 (CEST)
Message-ID: <1559212122.19553.1412714971908.open-xchange@webmail.nmp.skynet.be>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be> <20141007.161832.453892039501955243.davem@davemloft.net> <20141007203344.GA4748@roeck-us.net>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailsec111.isp.belgacom.be ([195.238.20.107]:45549 "EHLO
	mailsec111.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754139AbaJGUte convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 16:49:34 -0400
In-Reply-To: <20141007203344.GA4748@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 07 October 2014 at 22:33 Guenter Roeck <linux@roeck-us.net> wrote:
>
>
> On Tue, Oct 07, 2014 at 04:18:32PM -0400, David Miller wrote:
> > From: Fabian Frederick <fabf@skynet.be>
> > Date: Tue,=C2=A0 7 Oct 2014 22:16:36 +0200
> >
> > > static values are automatically initialized to NULL
> > >
> > > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> >
> > Isn't there some implementation room given to compilers
> > as to the representation of true and false?
>
> Not for true/false.
>
> C99 standard, section 7.16:
>
> ...
> The remaining three macros are suitable for use in #if preprocessing
> directives. They are
>
> true
>
> which expands to the integer constant 1,
>
> false
>
> which expands to the integer constant 0, and
> ...
>
> No idea where the NULL comes into the picture, though.
>
> Guenter

Maybe comment should have been "static values are automatically initial=
ized to
0" then ?

Regards,
=46abian
