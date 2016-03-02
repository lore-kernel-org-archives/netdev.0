From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 00/20] Sync man pages and help texts
Date: Wed, 2 Mar 2016 11:59:01 -0800
Message-ID: <20160302115901.6d9cd39c@xeon-e3>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52931 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbcCBT64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 14:58:56 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Feb 2016 09:21:13 +0100
Phil Sutter <phil@nwl.cc> wrote:

> This patch series aims at improving consistency of builtin help texts and
> related man pages (synopsis section at least). It was created by
> comparing the two and fixing up whatever occurred to be broken.
> 
> Phil Sutter (20):
>   ip: align help text with manpage
>   ipaddrlabel: Improve help text precision
>   iplink: fix help text syntax
>   ipneigh: add missing proxy keyword to help text
>   ipntable: Fix typo in help text
>   iproute: TYPE keyword is not optional, fix help text accordingly
>   iprule: add missing nat keyword to help text
>   man: ip-address.8: Minor syntax fixes
>   man: ip-link.8: minor font fix
>   man: ip-link.8: Fix and improve synopsis
>   man: ip-neighbour: Fix for missing NUD_STATE description
>   man: ip-netns.8: Clarify synopsis a bit
>   man: ip-ntable.8: Review synopsis section
>   man: ip-rule.8: Review synopsis section
>   man: ip-token.8: Review synopsis section
>   man: ip-tunnel.8: Document missing 6rd action
>   man: ip-xfrm.8: Document missing parameters
>   man: ip.8: Add missing flags and token subcommand description
>   man: ip-l2tp.8: Fix BNF syntax
>   man: ip-*.8: drop any reference to generic ip options
> 
>  ip/ip.c                  |   2 +-
>  ip/ipaddrlabel.c         |   3 +-
>  ip/iplink.c              |   9 ++--
>  ip/ipneigh.c             |   2 +-
>  ip/ipntable.c            |   2 +-
>  ip/iproute.c             |   6 +--
>  ip/iprule.c              |   1 +
>  man/man8/ip-address.8.in |   8 ++--
>  man/man8/ip-addrlabel.8  |  14 +-----
>  man/man8/ip-l2tp.8       |  24 ++++------
>  man/man8/ip-link.8.in    | 114 +++++++++++++++++++++++------------------------
>  man/man8/ip-monitor.8    |   4 +-
>  man/man8/ip-mroute.8     |   2 +-
>  man/man8/ip-neighbour.8  |  11 +++--
>  man/man8/ip-netns.8      |   4 +-
>  man/man8/ip-ntable.8     |  39 +++++++++-------
>  man/man8/ip-rule.8       |  19 +++++---
>  man/man8/ip-token.8      |  12 ++---
>  man/man8/ip-tunnel.8     |  11 +++--
>  man/man8/ip-xfrm.8       |  11 +++++
>  man/man8/ip.8            |  29 +++++++++++-
>  21 files changed, 181 insertions(+), 146 deletions(-)

Applied
