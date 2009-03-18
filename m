From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 09:13:55 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903180847180.8376@fbirervta.pbzchgretzou.qr>
References: <49C078B6.4020603@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34479 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754370AbZCRIN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 04:13:58 -0400
In-Reply-To: <49C078B6.4020603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2009-03-18 05:29, Patrick McHardy wrote:
>
> - logging:  logging using the nf_log mechsism using the primary backend.
>
>  Usage: "log [ prefix "prefix" ] [ group NUM ] [ snaplen NUM ]
>              [ queue-threshold NUM ]

Hm, how does one do traditional logging to syslog? Some of us just do
logging for debugging purposes and would not otherwise need the full-blown
nf_log solution - let alone there be enough space on some constrained
hardware for a thorough logger (say, WRT54).

> - limit: might be broken currently
>
>  Usage: "limit rate RATE/time-unit"

Does it use the old limit code (which has numerous accuracy problems
it seems), or will it magically make use of the rate estimator?

> The source code is available in three git trees:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nft-2.6.git
> git://git.netfilter.org/libnl-nft.git

The libnl repositories (both original and yours) is missing tags.
(Cc'ing Thomas).
The unannotated tags can be got from git://dev.medozas.de/libnl .

This makes it easier to get version numbers instead of
"cannot describe $sha1".

> git://git.netfilter.org/nftables.git

Missing a tag too, I think you (Patrick) can add it still :)

> The kernel tree will eventually also move to netfilter.org, currently
> the git daemon is unable to handle it because of memory shortage.
>
> Ths source code is considered alpha quality and is not meant for users
> at this time, it will spew quite a lot of debugging messages and
> definitely has bugs. Nevertheless, all of the basic features and most
> of the rest should work fine, the last crash has been several months
> ago. The two most noticable things that currently don't work is
> numerical argument parsing for arguments that have more specific types
> (f.i. port numbers), as well as reconstruction of the internal
> representation of sets and dictionaries using ranges. Both will be
> fixed shortly.

How about storing the actual text the user inputed in something like
an -m comment, as an aid to the user for finding his rules again
after they have been optimized internally?

