From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 11:21:02 -0700
Message-ID: <1250187662.28285.97.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>
	 <48AAB7CB-8EEC-4E30-B821-3E0D84531AAA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4016 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbZHMSVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 14:21:10 -0400
In-Reply-To: <48AAB7CB-8EEC-4E30-B821-3E0D84531AAA@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 14:15 -0400, Chuck Lever wrote:
> On Aug 13, 2009, at 2:10 PM, Joe Perches wrote:
> > The patch allows "%p6ic" for compressed and "%p6ic4" for compressed
> > with ipv4 last u32.
> 
> Why do these need to be separate?

Just an option.
I think it possible somebody will want "1::" instead of "1::0.0.0.0"


