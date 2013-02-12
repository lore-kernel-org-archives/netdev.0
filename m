From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Tue, 12 Feb 2013 18:55:06 +0000
Message-ID: <1360695306.3050.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov>
	 <20130211.200944.1447109432418679998.davem@davemloft.net>
	 <8EAAA907-914A-4670-BAAF-ABC95C0838CA@usgs.gov>
	 <20130211.235347.25383457019933412.davem@davemloft.net>
	 <A16FE98D-5476-4AB2-855F-0CDA3944E7F5@usgs.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Larry Baker <baker@usgs.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43953 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933876Ab3BLSzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 13:55:21 -0500
In-Reply-To: <A16FE98D-5476-4AB2-855F-0CDA3944E7F5@usgs.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 10:28 -0800, Larry Baker wrote:
> David,
> 
> On 11 Feb 2013, at 8:53 PM, David Miller wrote:
> 
> > 
> > Never email developers privately, ever.  It is both rude and
> > also a very poor use of global developer resources.
> > 
> > Always ask on the appropriate, public, mailing list, so that
> > any developer, not just me, can answer you.
> 
> I'm sorry you feel this way.  Other developers have been very gracious
> in offering assistance and encouragement to solve this problem.  I was
> following the instructions in Documentation/SubmittingPatches you
> guided me to.  Specifically, the instructions to locate the assigned
> maintainer and "e-mail that person".

It should also say to mail the related list(s); that's apparently a
documentation error.

> > 5) Select e-mail destination.
> > 
> > Look through the MAINTAINERS file and the source code, and determine
> > if your change applies to a specific subsystem of the kernel, with
> > an assigned maintainer.  If so, e-mail that person.  The script
> > scripts/get_maintainer.pl can be very useful at this step.
> > 
> > If no maintainer is listed, or the maintainer does not respond, send
> > your patch to the primary Linux kernel developer's mailing list,
> > linux-kernel@vger.kernel.org.  Most kernel developers monitor this
> > e-mail list, and can comment on your changes.
> 
> scripts/get_maintainer.pl said that was you.

David Miller is in overall charge of networking, so for any code under
drivers/net/ or net/ that doesn't have its own maintainer, he'll show up
as the primary maintainer.  But in reality I doubt he spends much time
thinking about relatively obscure areas that have lost their specialist
maintainer.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
