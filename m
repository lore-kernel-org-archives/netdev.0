From: Dan Williams <dcbw@redhat.com>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Fri, 27 Jul 2007 18:22:22 -0400
Message-ID: <1185574942.17934.9.camel@xo-13-A4-25.localdomain>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	 <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	 <20070727195616.GA31510@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Javier Cardona <javier@cozybit.com>, netdev@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S938236AbXG0WY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 18:24:28 -0400
In-Reply-To: <20070727195616.GA31510@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-27 at 20:56 +0100, Christoph Hellwig wrote:
> On Tue, Jul 03, 2007 at 12:29:24PM -0700, Javier Cardona wrote:
> > I'm currently working on per-packet mesh ttl.  My plan is to register
> > new mesh sockopts through netfilter.  The user interface will be:
> 
> NACK.  Drivers should never add sockopt, and drivers should not abuse
> netfilter hooks.

Do you have a suggestion for a better way to approach per-packet options
that userspace programs can set?

Thanks,
Dan


