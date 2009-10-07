From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: using huge numbers of queues
Date: Thu, 08 Oct 2009 00:22:28 +0100
Message-ID: <1254957748.2519.14.camel@localhost>
References: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28514 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbZJGXXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 19:23:12 -0400
In-Reply-To: <c0a09e5c0910071459r2768f420lae87f7404dfbc054@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-10-07 at 14:59 -0700, Andrew Grover wrote:
> Hi Herbert,
> 
> At NetConf, you made a passing remark about wanting lots of queues,
> even 1-per-socket. Have you thought further about how we would use so
> many?
> 
> Thinking about this reminded me of VJ's 2006 netchannel concept, which
> although not adopted, was pretty interesting. Would having 1 queue per
> socket (or at least 1 per process) and hw that is able to filter
> individual flows (I think the Intel 82599 can do this now for up to
> 128) perhaps make netchannels workable? At least this would get all
> processing out of int/bh and into process context, if not userspace,
> no?

Solarflare controllers already support 1000+ queues.  The OpenOnload
software <http://www.openonload.org> assigns one queue per process
(though this isn't quite 1:1 as sockets may be shared between processes)
and almost all protocol processing is done in user-space.  I'm not sure
quite how close this is to the netchannels concept.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

