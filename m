From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [PATCH] sctp: rfc conformance fixes
Date: Wed, 22 Oct 2008 16:01:27 +1100
Message-ID: <200810221601.27588.jk@ozlabs.org>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com> <1224650698.6597.32.camel@localhost.localdomain> <20081021.214725.176087242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: mbizon@freebox.fr, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35072 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751032AbYJVFBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 01:01:34 -0400
In-Reply-To: <20081021.214725.176087242.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Jeremy, patchwork doesn't try to interpret the subject line
> at all does it?  My impression is that it simply looked for
> patches in the email posting content and that's it.

That's correct - patchwork uses the content of the mail to determine if 
it contains a patch, not the subject.

Patchwork does make a few modifications to the subject though - mostly 
treatment of []-enclosed prefixes. For example, it removes [PATCH] from 
the subject line - if it's in patchwork, it's a patch :).

So, in this case, the following subjects:

 [RFC] fix breakage
 [PATCH,RFC] fix breakage
 [RFC,PATCH] fix breakage
 [PATCH/RFC] fix breakage

will all be normalised to:

 [RFC] fix breakage

Cheers,


Jeremy

