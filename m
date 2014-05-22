From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/4] isdn/capi: move capi_info2str to capidrv.c
Date: Thu, 22 May 2014 23:38:09 +0200
Message-ID: <1400794689.16407.57.camel@x220>
References: <cover.1400449368.git.tilman@imap.cc>
	 <365e4f40e1aace19c3233305085ed929b30387b8.1400449370.git.tilman@imap.cc>
	 <537D99F6.4040500@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de,
	"Keil, Karsten" <isdn@linux-pingi.de>
To: Karsten Keil <kkeil@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews05.kpnxchange.com ([213.75.39.8]:55780 "EHLO
	cpsmtpb-ews05.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751011AbaEVViL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 17:38:11 -0400
In-Reply-To: <537D99F6.4040500@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karsten,

On Thu, 2014-05-22 at 08:32 +0200, Karsten Keil wrote:
> Am 21.05.2014 23:39, schrieb Tilman Schmidt: 
> > capi_info2str() is apparently meant to be of general utility. It is
> > actually only used in capidrv.c. So move it from capiutil.c to
> > capidrv.c and (obviously) stop exporting it.
> > 
> > And, since we're touching this, merge the two versions of this
> > function.
>
> I disagree here, since this is a general helper function and should be
> not in a special driver, but stay in capiutils.c which is the place for
> the driver independent stuff. I used this function from time to time to
> instrument other places for debugging as well.

Thanks for commenting. It would be nice if you could also comment on
patch 4/4. You might be able to tell whether the things I say there
about, well, the history of CAPI (middleware) device nodes are correct,
as you were already maintainer during that period, weren't you?

This patch, 1/4, and patch 2/4, simplify the Kconfig file and the code a
bit. It makes it  bit easier to understand how the CAPI code fits
together. Same thing with my commit d1958f8c2f0d ("isdn/capi: Make
Middleware depend on CAPI2.0"). It is also nice to drop the
ISDN_DRV_AVMB1_VERBOSE_REASON name, which only makes sense to people
that know the ancient history of this code.

Anyhow, this patch might complicate your local debugging practices. That
might be inconvenient for you. But in mainline we see a function that's
used in one place only. And I think cleaning up mainline code is what
counts.


Paul Bolle
