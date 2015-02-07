From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch
 errors
Date: Sat, 7 Feb 2015 19:02:40 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1502071902060.2050@localhost6.localdomain6>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com> <1423328797-17865-3-git-send-email-baspeters93@gmail.com> <54D650BF.5000400@cogentembedded.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:14372 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758519AbbBGSCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 13:02:42 -0500
In-Reply-To: <54D650BF.5000400@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 7 Feb 2015, Sergei Shtylyov wrote:

> Hello.
> 
> On 02/07/2015 08:06 PM, Bas Peters wrote:
> 
> > This patch fixes the following checkpatch errors:
> > 	1. trailing statement
> > 	1. assignment of variable in if condition
> > 	1. incorrectly placed brace after function definition
> 
> > Signed-off-by: Bas Peters <baspeters93@gmail.com>
> > ---
> >   drivers/isdn/act2000/capi.c | 9 ++++++---
> >   1 file changed, 6 insertions(+), 3 deletions(-)
> 
> > diff --git a/drivers/isdn/act2000/capi.c b/drivers/isdn/act2000/capi.c
> > index 3f66ca2..5d677e6 100644
> > --- a/drivers/isdn/act2000/capi.c
> > +++ b/drivers/isdn/act2000/capi.c
> > @@ -113,7 +113,8 @@ actcapi_chkhdr(act2000_card *card, actcapi_msghdr *hdr)
> >   			m->hdr.cmd.cmd = c;			\
> >   			m->hdr.cmd.subcmd = s;			\
> >   			m->hdr.msgnum = actcapi_nextsmsg(card); \
> > -		} else m = NULL;				\
> > +		} else

It looks like a \ was lost on this line.  It should have caused a compiler 
error.

julia

> > +			m = NULL;				\
> 
>    Documentation/CodingStyle has an extra rule for such case: *else* branch
> should also have {} since *if* branch has {}.
> 
> [...]
> 
> WNR, Sergei
> 
> 
