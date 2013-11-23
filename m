From: Michele Baldessari <michele@acksyn.org>
Subject: Re: Bug - regression - Via velocity interface coming up freezes
 kernel
Date: Sat, 23 Nov 2013 18:28:49 +0000
Message-ID: <20131123182849.6d742f82@fante.int.rhx>
References: <CAFES+i+OYq_dDtEqAqkW7qYDrtdzkqc9hBGBDODQuqgvFJE7zg@mail.gmail.com>
	<20130922221109.GA14246@electric-eye.fr.zoreil.com>
	<20131111234656.GA4846@marquez.int.rhx>
	<20131114072451.GA2313@electric-eye.fr.zoreil.com>
	<20131115000113.GA22051@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Dirk Kraft <dirk.kraft@gmail.com>, netdev@vger.kernel.org,
	Julia Lawall <Julia.Lawall@lip6.fr>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:43406 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755539Ab3KWS2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 13:28:52 -0500
In-Reply-To: <20131115000113.GA22051@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois,

On Fri, 15 Nov 2013 01:01:13 +0100 
Francois Romieu <romieu@fr.zoreil.com> wrote:
> Francois Romieu <romieu@fr.zoreil.com> :
> > Michele Baldessari <michele@acksyn.org> :
> > [...]
> > > any chance you can submit this officially ?
> > 
> > Yes.
> > 
> > > Or does this patch need some more work ?
> > 
> > I'll write some narrative for the commit message.
> 
> I would actually rather send the patch below.
> 
> The previous patch isn't safe against mtu changes. Please give the
> patch below some testing. Test case: receive lots of packets while
> changing MTU. Loop. The former patch may crash. The later shouldn't.

testing was performed by Alex A. Schmidt on this second patch variant
with MTU changes and no crashes were observed. Is the patch good
to go now?

thanks,
Michele
