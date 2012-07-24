From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Tue, 24 Jul 2012 07:11:21 -0400
Message-ID: <20120724111120.GA14840@zod.bos.redhat.com>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
 <1343106407.2626.11038.camel@edumazet-glaptop>
 <20120724053811.GA12053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?iso-8859-1?Q?Villac=EDs?= Lasso
	<a_villacis@palosanto.com>, Tom Herbert <therbert@google.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab2GXLLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 07:11:47 -0400
Content-Disposition: inline
In-Reply-To: <20120724053811.GA12053@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 24, 2012 at 07:38:11AM +0200, Francois Romieu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> :
> > On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> > > This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
> [...]
> > bisection is not always the right way to qualify a problem.
> 
> I know. At some point I switch from "I could search more" to "users situation
> will improve in a definite timeframe".
> 
> > BQL in itself had some fixes coming _after_ commit 036dafa28da1e2565
> 
> Thanks.
> 
> They are in stable as of 3.4.5:
> 
> commit 4f4bdaeb40df95499c1ee7ea3fbca9d76174a59e
> Author:     Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> AuthorDate: Wed May 30 12:25:37 2012 +0000
> Commit:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> CommitDate: Mon Jul 16 09:03:43 2012 -0700
> 
>     bql: Avoid possible inconsistent calculation.
>     
>     [ Upstream commit 914bec1011a25f65cdc94988a6f974bfb9a3c10d ]
> [...]
> commit 1414a53d956340ca8b1b27e05ab94ba63e82ed97
> Author:     Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> AuthorDate: Wed May 30 12:25:19 2012 +0000
> Commit:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> CommitDate: Mon Jul 16 09:03:43 2012 -0700
> 
>     bql: Avoid unneeded limit decrement.
> 
> I have obviously not directed users at them and I do not see any
> of the victims using a non -stable / -vendor or recent enough
> kernel to test this patch since the issue has been reported.
> 
> They are both worth testing.

Fedora has 3.4.5 in the F16 updates-testing repo.  F17 is already on
3.4.6 in stable updates.  Users should be able to use those kernels for
testing.  F16 will be getting 3.4.6 submitted this morning for
updates-testing.

josh
