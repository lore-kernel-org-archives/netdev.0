From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 08:07:36 -0700
Message-ID: <1250176056.28285.77.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com>  <1250159961.28285.35.camel@Joe-Laptop.home>
	 <1250171543.6641.78.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3743 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbZHMPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 11:07:40 -0400
In-Reply-To: <1250171543.6641.78.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 15:52 +0200, Jens Rosenboom wrote:
> On Thu, 2009-08-13 at 03:39 -0700, Joe Perches wrote:
> > You'll need to invent a new %p qualifier type to allow
> > compressed representation.  Your patch will change current uses
> > with seq_<foo> output in net, which could break userspace.
> 
> Would it be possible to transform this to using %pi6, as most of teh
> seq_* stuff already does?

No.

There are applications that depend on the
current output representation.

I think it should be done with something like "%pi6c" 
rather than using another %p character because there
are a limited number of single characters available.

