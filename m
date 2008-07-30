From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [patch 09/11] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 16:54:27 -0700
Message-ID: <1217462067.4338.0.camel@brick>
References: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
	 <20080730.164236.246400895.davem@davemloft.net>
	 <20080730165207.b8e62eb5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	samuel@sortiz.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:47399 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbYG3Xyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:54:31 -0400
Received: by wf-out-1314.google.com with SMTP id 27so375373wfd.4
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 16:54:30 -0700 (PDT)
In-Reply-To: <20080730165207.b8e62eb5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-30 at 16:52 -0700, Andrew Morton wrote:
> On Wed, 30 Jul 2008 16:42:36 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: akpm@linux-foundation.org
> > Date: Wed, 30 Jul 2008 12:37:42 -0700
> > 
> > > From: Harvey Harrison <harvey.harrison@gmail.com>
> > > 
> > > __FUNCTION__ is gcc-specific, use __func__
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > > Cc: Samuel Ortiz <samuel@sortiz.org>
> > > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > 
> > This gets rejects because it conflicts with the down_try()
> > changes that went into Linus's tree recently.  Specifically
> > this occurs in sir_dev.c
> 
> urgh, OK, sorry.  I'll hang onto it, see how we get along next time.

I'll try again at -rc2 time perhaps?  Or I can just regen later tonight
and resend if you prefer.

Harvey

