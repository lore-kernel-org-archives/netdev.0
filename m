From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/4] Smaller link type help review
Date: Tue, 4 Apr 2017 14:53:59 -0700
Message-ID: <20170404145359.09e754d2@xeon-e3>
References: <20170328211939.17922-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33872 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753834AbdDDVyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:54:06 -0400
Received: by mail-pf0-f182.google.com with SMTP id 197so13095158pfv.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:54:06 -0700 (PDT)
In-Reply-To: <20170328211939.17922-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Mar 2017 23:19:35 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series addresses some minor nits with link type specific help
> texts:
> 
> * Unify coding style of print_help() callbacks (or the functions they
>   call.
> 
> * Unify output as much as possible for a common look and feel.
> 
> * Make sure there's type specific help for each type listed in 'ip link
>   help'.
> 
> Phil Sutter (4):
>   ip: link: bond: Fix whitespace in help text
>   ip: link: macvlan: Add newline to help output
>   ip: link: Unify link type help functions a bit
>   ip: link: Add missing link type help texts
> 
>  ip/Makefile         |  3 ++-
>  ip/iplink_bond.c    |  2 +-
>  ip/iplink_dummy.c   | 16 ++++++++++++++++
>  ip/iplink_geneve.c  | 28 ++++++++++++++++++----------
>  ip/iplink_ifb.c     | 16 ++++++++++++++++
>  ip/iplink_ipoib.c   |  4 +++-
>  ip/iplink_macvlan.c |  1 +
>  ip/iplink_nlmon.c   | 16 ++++++++++++++++
>  ip/iplink_team.c    | 25 +++++++++++++++++++++++++
>  ip/iplink_vcan.c    | 16 ++++++++++++++++
>  ip/iplink_vlan.c    | 15 +++++++++------
>  ip/iplink_vxlan.c   | 44 +++++++++++++++++++++++++++++---------------
>  ip/link_gre.c       | 36 +++++++++++++++++++++++-------------
>  ip/link_gre6.c      | 47 ++++++++++++++++++++++++++++-------------------
>  ip/link_ip6tnl.c    | 46 +++++++++++++++++++++++++++-------------------
>  ip/link_iptnl.c     | 38 ++++++++++++++++++++++++++------------
>  ip/link_vti.c       | 17 +++++++++--------
>  17 files changed, 265 insertions(+), 105 deletions(-)
>  create mode 100644 ip/iplink_dummy.c
>  create mode 100644 ip/iplink_ifb.c
>  create mode 100644 ip/iplink_nlmon.c
>  create mode 100644 ip/iplink_team.c
>  create mode 100644 ip/iplink_vcan.c
> 

All 4 Applied
