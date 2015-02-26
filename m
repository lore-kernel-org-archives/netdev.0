From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] bridge: Show state names in the 'link help'
 print
Date: Thu, 26 Feb 2015 03:03:50 +0200
Message-ID: <20150226010350.GA13245@angus-think.lan>
References: <1424908593-4524-1-git-send-email-vadim4j@gmail.com>
 <20150225170950.06b81a78@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:42916 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbBZBPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 20:15:11 -0500
Received: by lbiw7 with SMTP id w7so7716943lbi.9
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 17:15:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150225170950.06b81a78@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 05:09:50PM -0800, Stephen Hemminger wrote:
> On Thu, 26 Feb 2015 01:56:33 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> >  bridge/link.c | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/bridge/link.c b/bridge/link.c
> > index a7bd85f..7f1ec70 100644
> > --- a/bridge/link.c
> > +++ b/bridge/link.c
> > @@ -228,6 +228,12 @@ static void usage(void)
> >  	fprintf(stderr,	"                               [ flood {on | off} ]\n");
> >  	fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
> >  	fprintf(stderr, "       bridge link show [dev DEV]\n");
> > +	fprintf(stderr, "\n");
> > +	fprintf(stderr, "STATE := { 0 | disabled   |\n");
> > +	fprintf(stderr, "           1 | listening  |\n");
> > +	fprintf(stderr, "           2 | learning   |\n");
> > +	fprintf(stderr, "           3 | forwarding |\n");
> > +	fprintf(stderr, "           4 | blocking }\n");
> >  	exit(-1);
> >  }
> >  
> 
> that is too wordy for help. put it in docs if needed.

Hm, I assumed this might be useful for fast looking for state names from the shell just by 'link help'...
