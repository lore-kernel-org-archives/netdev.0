From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH iproute2 v2 0/2] Fix compiler-errors with gcc 4.7.3
Date: Mon, 22 Jul 2013 20:03:53 +0200
Message-ID: <20130722180353.GA3558@cpaasch-mac>
References: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
 <20130722103432.396f13db@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:57629 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932264Ab3GVSD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 14:03:57 -0400
Received: by mail-we0-f182.google.com with SMTP id u55so1509977wes.13
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 11:03:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130722103432.396f13db@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/07/13 - 10:34:32, Stephen Hemminger wrote:
> On Mon, 22 Jul 2013 19:24:15 +0200
> Christoph Paasch <christoph.paasch@uclouvain.be> wrote:
> 
> > gcc complains about unused return-values in ss.c and lnstat_util.c
> > 
> > Christoph Paasch (2):
> >   ss: Fix compiler errors of unused return-values
> >   lnstat: Fix compiler errors of unused return-values
> > 
> >  misc/lnstat_util.c | 12 ++++++++----
> >  misc/ss.c          | 33 ++++++++++++++++++++++++---------
> >  2 files changed, 32 insertions(+), 13 deletions(-)
> > 
> 
> I think just turning on -Werror is less ugly.

I guess you mean turning -Werror off?

For me that's fine too, as long as iproute compiles on my machine. Should I
make a patch that removes -Werror?
