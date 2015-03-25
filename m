From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH iproute2 2/2] ip: Harmonise usage references to show /
 list option
Date: Wed, 25 Mar 2015 09:26:44 +0000
Message-ID: <20150325092644.GA5667@leicester.auvation.com>
References: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
 <1426499950-6641-2-git-send-email-mark.einon@gmail.com>
 <20150324145315.754c6ff3@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [81.174.139.2] ([81.174.139.2]:58995 "EHLO mail.einon.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751118AbbCYJfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 05:35:06 -0400
Content-Disposition: inline
In-Reply-To: <20150324145315.754c6ff3@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 02:53:15PM -0700, Stephen Hemminger wrote:
> On Mon, 16 Mar 2015 09:59:10 +0000
> Mark Einon <mark.einon@gmail.com> wrote:
> 
> > diff --git a/ip/iproute.c b/ip/iproute.c
> > index c842e85..b863e7b 100644
> > --- a/ip/iproute.c
> > +++ b/ip/iproute.c
> > @@ -59,7 +59,7 @@ static void usage(void) __attribute__((noreturn));
> >  
> >  static void usage(void)
> >  {
> > -	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");
> 
> Sorry, this sounds like a good idea until I went and checked what
> is shown on the man pages.
> 
> The ip route man page has:
> 
>        ip route { list | flush } SELECTOR
> 
> For me, it is more important that the usage match the man page,
> rather than having all usage messages match.

Thanks for the review Stephen. So, I'm assuming that a set of patches
with corresponding man page fixes would be acceptable? I was going to
look at those next anyway, time permitting.

Mark
