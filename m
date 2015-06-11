From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: isdn: pcbit: another off-by-one issue?
Date: Thu, 11 Jun 2015 13:44:20 +0200
Message-ID: <1434023060.2271.105.camel@x220>
References: <87381zqr4y.fsf@rasmusvillemoes.dk>
	 <20150611075852.GE11734@mwanda> <87mw06egrg.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud3.xs4all.net ([194.109.24.22]:60992 "EHLO
	lb1-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752064AbbFKLoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 07:44:25 -0400
In-Reply-To: <87mw06egrg.fsf@rasmusvillemoes.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-06-11 at 11:28 +0200, Rasmus Villemoes wrote:
> Since nobody seems to have been hit by this ever, I wonder whether it's
> stable@ material. It probably doesn't make sense to fix this without
> also backporting 7bcc6738eef.

I'm guessing nobody is using this anymore. I would be really surprised
if anyone is. Let's test my idea. Hands up anyone that has:
- a PCBIT ISDN-card ("manufactured in Portugal by Octal", according to
  its Kconfig entry);
- a working X86 machine with ISA;
- a working ISDN line;
- and, say, an ISP picking up the stuff you send down that ISDN line
  at the other end;
- and cares how 2.6.32 (and higher) runs that setup.

[Crickets.]

Besides, it is, apparently, an I4L driver. (Though there's a CAPI part
too. I need to check how that fits into the picture.) I4L is deprecated
for ten years now (or is it even longer?).

Perhaps pcbit, and the other I4L drivers, should be (finally) tossed
out? That was discussed last year too, but nothing really was decided.


Paul Bolle
