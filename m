From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag"
 (802.1p packet)
Date: Mon, 14 Jun 2010 12:42:53 -0700
Message-ID: <1276544573.4897.6.camel@Joe-Laptop.home>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>
	 <1276466190.14011.223.camel@localhost>
	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com>
	 <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
	 <4C1662C3.3070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Pedro Garcia <pedro.netdev@dondevamos.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1128 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750937Ab0FNTm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 15:42:56 -0400
In-Reply-To: <4C1662C3.3070708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-14 at 19:11 +0200, Patrick McHardy wrote:
> Ben Hutchings wrote:
> > On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
> >> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
> >> <bhutchings@solarflare.com> wrote:
> >>> I have no particular opinion on this change, but you need to read and
> >>> follow Documentation/SubmittingPatches.
> >> Sorry, first kernel patch, and I did not know about it. I resubmit with
> >> the correct style / format:
> > Sorry, no you haven't.
> > - Networking changes go through David Miller's net-next-2.6 tree so you
> > need to use that as the baseline, not 2.6.26
> > - Patches should be applicable with -p1, not -p0 (so if you use diff,
> > you should run it from one directory level up)
> > - The patch was word-wrapped

Pedro, you could use git format-patch and git send-email
http://linux.yyz.us/git-howto.html
http://www.kernel.org/pub/software/scm/git/docs/git-format-patch.html

> Additionally:
> - the pr_debug statements may be useful for debugging, but are
>   a bit excessive for the final version

Patrick, what's wrong with pr_debug?
Do you prefer pr_devel?

> - Please CC the maintainer (which is me)

scripts/get_maintainer.pl 

