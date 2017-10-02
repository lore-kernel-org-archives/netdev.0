From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 0/3] Check user supplied interface name
 lengths
Date: Mon, 2 Oct 2017 08:03:09 -0700
Message-ID: <20171002080309.1d7f4099@xeon-e3>
References: <20171002114637.25703-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:53134 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdJBPDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 11:03:16 -0400
Received: by mail-pg0-f47.google.com with SMTP id i195so3095315pgd.9
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 08:03:16 -0700 (PDT)
In-Reply-To: <20171002114637.25703-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  2 Oct 2017 13:46:34 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This series adds explicit checks for user-supplied interface names to
> make sure they fit Linux's requirements.
> 
> The first two patches simplify interface name parsing in some places -
> these are side-effects of working on the actual implementation provided
> in patch three.
> 
> Changes since v2:
> - Changed patch 3 as suggested in review.
> 
> Changes since v1:
> - Patches 1 and 2 introduced.
> - Changes to patch 3 are listed in there.
> 
> Phil Sutter (3):
>   ip{6,}tunnel: Avoid copying user-supplied interface name around
>   tc: flower: No need to cache indev arg
>   Check user supplied interface name lengths
> 
>  include/utils.h |  2 ++
>  ip/ip6tunnel.c  |  9 +++++----
>  ip/ipl2tp.c     |  4 +++-
>  ip/iplink.c     | 31 ++++++++++++-------------------
>  ip/ipmaddr.c    |  3 ++-
>  ip/iprule.c     | 10 ++++++++--
>  ip/iptunnel.c   | 29 +++++++++++++++--------------
>  ip/iptuntap.c   |  6 ++++--
>  lib/utils.c     | 29 +++++++++++++++++++++++++++++
>  misc/arpd.c     |  3 ++-
>  tc/f_flower.c   |  7 +++----
>  11 files changed, 85 insertions(+), 48 deletions(-)
> 

Applied.
