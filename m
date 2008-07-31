From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/11] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 17:04:32 -0700
Message-ID: <20080730170432.8daf3c38.akpm@linux-foundation.org>
References: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
	<20080730.164236.246400895.davem@davemloft.net>
	<20080730165207.b8e62eb5.akpm@linux-foundation.org>
	<1217462067.4338.0.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, samuel@sortiz.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41762 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757541AbYGaAEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 20:04:39 -0400
In-Reply-To: <1217462067.4338.0.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 16:54:27 -0700
Harvey Harrison <harvey.harrison@gmail.com> wrote:

> On Wed, 2008-07-30 at 16:52 -0700, Andrew Morton wrote:
> > On Wed, 30 Jul 2008 16:42:36 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> > 
> > > From: akpm@linux-foundation.org
> > > Date: Wed, 30 Jul 2008 12:37:42 -0700
> > > 
> > > > From: Harvey Harrison <harvey.harrison@gmail.com>
> > > > 
> > > > __FUNCTION__ is gcc-specific, use __func__
> > > > 
> > > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > > > Cc: Samuel Ortiz <samuel@sortiz.org>
> > > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > This gets rejects because it conflicts with the down_try()
> > > changes that went into Linus's tree recently.  Specifically
> > > this occurs in sir_dev.c
> > 
> > urgh, OK, sorry.  I'll hang onto it, see how we get along next time.
> 
> I'll try again at -rc2 time perhaps?  Or I can just regen later tonight
> and resend if you prefer.
> 

Could.  But that would muck up Rusty's patch, or linux-next.

Then again, Rusty's full down_try() patch won't be making it into
2.6.27 and David tends to merge little cleanups like this into -rc2 (or
later) so perhaps that's the way to go.

<fixes that reject for the twelfth time>

I'll resend.

