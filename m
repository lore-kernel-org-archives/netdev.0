From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25.6: warn_on_slowpath in tcp_input.c
Date: Thu, 17 Jul 2008 18:01:02 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807171744130.13775@wrl-59.cs.helsinki.fi>
References: <20080630230954.GS16698@anguilla.noreply.org>
 <396556a20806301656ydc44e3ey6deb229ab69904@mail.gmail.com>
 <20080701073833.GT16698@anguilla.noreply.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Adam Langley <agl@imperialviolet.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Peter Palfrader <peter@palfrader.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58232 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbYGQPBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 11:01:19 -0400
In-Reply-To: <20080701073833.GT16698@anguilla.noreply.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jul 2008, Peter Palfrader wrote:

> On Mon, 30 Jun 2008, Adam Langley wrote:
> 
> > On Mon, Jun 30, 2008 at 4:09 PM, Peter Palfrader <peter@palfrader.org> wrote:
> > > I've had 13 or so of them since upgrading the machine to a 2.6.25 kernel
> > > 20 days ago.
> > >
> > > Linux saens 2.6.25.6-dl380 #2 SMP Tue Jun 10 17:54:44 CEST 2008 i686 GNU/Linux
> >
> > Which kernel was it running before?
> 
> It was running 2.6.22.17 (+ the splice fix) before that.

Thanks for the report, I've been away for a while, thus the late response.
Please update to get this relevant fix and some other TCP fixes (if you 
haven't yet):

 releases/2.6.25.7/tcp-fix-skb-vs-fack_count-out-of-sync-condition.patch

...If you still get them afterwards, please do rereport (and include me 
as recipient :-)). ...I know there are couple of cases still after that 
fix where TCP invariant checks trigger but they've been rare enough to 
evade any of my debugging attempts (2.6.22.17 won't warn you anyway when 
it breaks an invariant though I already know a handful violations that 
do occur with it too but there's just plain silence because I only later 
on added those warning).


-- 
 i.
