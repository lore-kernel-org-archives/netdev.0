From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 0/2] vxlan: add configuration check
Date: Mon, 5 Sep 2016 12:30:02 +0200
Message-ID: <20160905103002.GE29816@orbyte.nwl.cc>
References: <cover.1473067954.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36228 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932444AbcIEKaF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:30:05 -0400
Content-Disposition: inline
In-Reply-To: <cover.1473067954.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 05, 2016 at 11:35:26AM +0200, Jiri Benc wrote:
> Mirror the vxlan configuration check recently added to the kernel.
> 
> While at this, I also converted open coded IPv6 address comparisons to the
> standard macros.
> 
> Jiri Benc (2):
>   tunnels: use macros for IPv6 address comparison
>   vxlan: group address requires net device
> 
>  ip/ip6tunnel.c     |  8 ++++----
>  ip/iplink_geneve.c |  6 +++---
>  ip/iplink_vxlan.c  | 19 ++++++++++++-------
>  3 files changed, 19 insertions(+), 14 deletions(-)

Series:
Acked-by: Phil Sutter <phil@nwl.cc>
