From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] IPV6: checkpatch corrections
Date: Sat, 16 Aug 2014 09:08:20 -0700
Message-ID: <1408205300.2683.63.camel@joe-AO725>
References: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0222.hostedemail.com ([216.40.44.222]:57750 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751531AbaHPQIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 12:08:24 -0400
In-Reply-To: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-08-16 at 13:04 +0100, Ian Morris wrote:
> No changes to logic, just whitespace adjustments to coding style : tab/space cleanup.
> objdump shows no differences
> diff -w shows no differences

Hello again Ian.

Some minor notes:

You should also use a cover letter so that
the patches are threaded better.

	"git format-patch --cover-letter"

A cover makes it easier to apply and makes
it easier to reply to a subject for all of
the patches but not a specific one.

The patches seem fine, but the patch subjects
should be different for all 4 of these.

This one should be something like:

ipv6: convert spaces to tabs

and the others;

ipv6: Neaten structure definitions
ipv6: Move EXPORT_SYMBOL after declarations
ipv6: Neaten brace and break style

These are patches that are not going to be
applied to the current net repo, but could be
applied to the net-next repo.

So please send these with a "[PATCH net-next]"
patch prefix.  You can do that with:

git format-patch --subject-prefix="PATCH net-next"

Lastly, the net-next tree is not "open" now.

During the "merge window", immediately after a
non -rc release, when changes are pulled from
various maintainer trees to the master one,
changes to these maintainer trees are generally
frozen and not accepted from others.

It takes about 3 weeks between the start of the
merge window until the -net-next tree is open
for changes again.

David Miller sends an announcement email for
both events to the netdev mailing list.

A lot of this is documented here:
https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt
