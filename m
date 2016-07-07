From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 iproute2 0/6] Add support for vrf keyword
Date: Wed, 6 Jul 2016 21:29:23 -0700
Message-ID: <20160706212923.1a8c5cd7@xeon-e3>
References: <1467224822-16773-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32993 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbcGGE3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 00:29:09 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so2622853pat.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 21:29:08 -0700 (PDT)
In-Reply-To: <1467224822-16773-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jun 2016 11:26:56 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Currently the syntax for VRF related commands is rather kludgy and
> inconsistent from one subcommand to another. This set adds support
> for the VRF keyword to the link, address, neigh, and route commands
> to improve the user experience listing data associated with vrfs,
> modifying routes or doing a route lookup.
> 
> v4
> - Stephen's comments about patch 1 also apply to patch 5, so updated it
> v3
> - addressed comments from Stephen
> - added documentation updates to patches 2, 3 and 6
> 
> v2
> - rebased to top of tree
> - all checkpatch warnings are usage lines. The change in these
>   patches is consistent with existing code for usage lines
> 
> David Ahern (6):
>   ip vrf: Add name_is_vrf
>   ip link/addr: Add support for vrf keyword
>   ip neigh: Add support for keyword
>   ip route: Change type mask to bitmask
>   ip vrf: Add ipvrf_get_table
>   ip route: Add support for vrf keyword
> 
>  ip/ip_common.h           |   3 ++
>  ip/ipaddress.c           |  12 ++++-
>  ip/iplink.c              |  15 ++++++-
>  ip/iplink_vrf.c          | 113 +++++++++++++++++++++++++++++++++++++++++++++++
>  ip/ipneigh.c             |  14 +++++-
>  ip/iproute.c             |  43 +++++++++++++++---
>  man/man8/ip-address.8.in |   6 +++
>  man/man8/ip-link.8.in    |  10 +++++
>  man/man8/ip-neighbour.8  |   8 +++-
>  man/man8/ip-route.8.in   |  19 +++++++-
>  10 files changed, 230 insertions(+), 13 deletions(-)
> 

Applied, thanks for cleaning it up.
