From: "Luis Carlos Cobo" <luisca@cozybit.com>
Subject: Re: Proposed interface for per-packet mesh-ttl
Date: Thu, 16 Aug 2007 15:43:16 -0700
Message-ID: <8e8340660708161543l1b4de41at861fbb98463f39e8@mail.gmail.com>
References: <445f43ac0707031149o2b50fc0en48aef4130b4b60ec@mail.gmail.com>
	 <445f43ac0707031229m4ed60e0cg7960437c3e373c8e@mail.gmail.com>
	 <20070727195616.GA31510@infradead.org>
	 <1185574942.17934.9.camel@xo-13-A4-25.localdomain>
	 <20070728073145.57155e03@oldman>
	 <445f43ac0707301337l2f7d62ebx6955a12cd89c6bd3@mail.gmail.com>
	 <20070730215316.5c236e18@oldman>
	 <8e8340660708161221t1c0bee01g9d0cb1835f7026f0@mail.gmail.com>
	 <20070816171913.2ad87e47@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Javier Cardona" <javier@cozybit.com>,
	"Dan Williams" <dcbw@redhat.com>,
	"Christoph Hellwig" <hch@infradead.org>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:63545 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbXHPWnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 18:43:18 -0400
Received: by py-out-1112.google.com with SMTP id u77so608551pyb
        for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 15:43:17 -0700 (PDT)
In-Reply-To: <20070816171913.2ad87e47@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/16/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> The problem with socket options is how does the application know
> the correct policy? Pushing configuration to application is just deferring
> the problem, not solving it.  You want some policy to be done by the
> infrastructure; that means kernel, libraries, daemons, etc. Doing it in
> the application is often inflexible and unusable.

The policy will usually be done by the kernel. If the flag is not set,
which will happen most of the time, the driver will use a sensible
default ttl. The socket option would only be used by applications that
are specifically interested in a configurable ttl (like an application
to plot neighbors within an specific diameter). A per-interface
setting is not good enough, since we do not want the neighbor-plotting
tool to affect the ttl of other connections (e.g. a ssh session) that
might be going on at the same time.

-- 
Luis Carlos Cobo Rus       GnuPG ID: 44019B60
cozybit Inc.
