From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Sat, 28 Jul 2007 07:31:45 +0100
Message-ID: <20070728073145.57155e03@oldman>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	<445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	<20070727195616.GA31510@infradead.org>
	<1185574942.17934.9.camel@xo-13-A4-25.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Javier Cardona <javier@cozybit.com>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49158 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751879AbXG1Gbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2007 02:31:51 -0400
In-Reply-To: <1185574942.17934.9.camel@xo-13-A4-25.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Jul 2007 18:22:22 -0400
Dan Williams <dcbw@redhat.com> wrote:

> On Fri, 2007-07-27 at 20:56 +0100, Christoph Hellwig wrote:
> > On Tue, Jul 03, 2007 at 12:29:24PM -0700, Javier Cardona wrote:
> > > I'm currently working on per-packet mesh ttl.  My plan is to register
> > > new mesh sockopts through netfilter.  The user interface will be:
> > 
> > NACK.  Drivers should never add sockopt, and drivers should not abuse
> > netfilter hooks.
> 
> Do you have a suggestion for a better way to approach per-packet options
> that userspace programs can set?
> 
> Thanks,
> Dan

In this case perhaps you can have a table that maps skb->priority to
mesh ttl? priorty can already by handled by existing setsockopt calls,
and modified by netfilter and QoS managements.
