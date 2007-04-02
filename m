From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: SWS for rcvbuf < MTU
Date: Mon, 2 Apr 2007 16:01:13 -0400
Message-ID: <200704021601.13742.alexandre.sidorenko@hp.com>
References: <200703021521.58821.alexandre.sidorenko@hp.com> <45F6F51E.6090905@psc.edu> <200703141218.57179.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:49063 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965764AbXDBUBG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 16:01:06 -0400
In-Reply-To: <200703141218.57179.alexandre.sidorenko@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 14, 2007 12:18:56 pm Alex Sidorenko wrote:
> On March 13, 2007 03:01:50 pm John Heffner wrote:
> > Sorry for the long delay in response, I've been on vacation. =A0I'm=
 okay
> > with your patch, and I can't think of any real problem with it, exc=
ept
> > that the behavior is non-standard. =A0Then again, Linux acking in g=
eneral
> > is non-standard, which has created the bug in the first place. :) =A0=
The
> > only thing I can think where it might still ack too often is if
> > free_space frequently drops just below full_space/2 for a bit then =
rises
> > above full_space/2.
> >
> > I've also attached a corrected version of my earlier patch that I t=
hink
> > solves the problem you noted.
>
> Hello John,
>
> I think your corrected version should avoid the problem I mentioned, =
but I
> will still ask the customer to test the new version. It will be inter=
esting
> to compare traffic patterns with those observed with stock kernel and=
 my
> earlier patch.
>
> It might take some time to do proper testing, I'll inform you as soon=
 as
> there are any results.

Hello John,

our customer has tested your patch thoroughly and everything's working =
fine.=20
Please apply the patch if this is not done yet.

Thanks,
Alex

--=20
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
