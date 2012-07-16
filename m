From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: resurrecting tcphealth
Date: Mon, 16 Jul 2012 14:32:37 +0100
Message-ID: <1342445557.2523.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <cc6495b92f1df180c1ad43057ceb0b98.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Piotr Sawuk <a9702387@unet.univie.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24968 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751484Ab2GPNck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 09:32:40 -0400
In-Reply-To: <cc6495b92f1df180c1ad43057ceb0b98.squirrel@webmail.univie.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-14 at 09:56 +0200, Piotr Sawuk wrote:
> On Sa, 14.07.2012, 03:31, valdis.kletnieks@vt.edu wrote:
> > On Fri, 13 Jul 2012 16:55:44 -0700, Stephen Hemminger said:
> >
> >> >+			/* Course retransmit inefficiency- this packet has been received
> >> twice. */
> >> >+			tp->dup_pkts_recv++;
> >> I don't understand that comment, could you use a better sentence please?
> >
> > I think what was intended was:
> >
> > /* Curse you, retransmit inefficiency! This packet has been received at
> least twice */
> >
> 
> LOL, no. I think "course retransmit" is short for "course-grained timeout
> caused retransmit" but I can't be sure since I'm not the author of these
> lines. I'll replace that comment with the non-shorthand version though.
> however, I think the real comment here should be:
[...]

The word you are looking for is 'coarse' not 'course' (they are
generally pronounced the same, to confuse you).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
