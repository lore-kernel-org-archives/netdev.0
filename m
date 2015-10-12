From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH 0/3] improve MACVLAN/MACVTAP support
Date: Mon, 12 Oct 2015 09:48:13 -0700
Message-ID: <20151012094813.19ee60ea@urahara>
References: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35879 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbbJLQsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:48:01 -0400
Received: by pacex6 with SMTP id ex6so4434993pac.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:48:00 -0700 (PDT)
In-Reply-To: <1443182991-4628-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Sep 2015 14:09:48 +0200
Phil Sutter <phil@nwl.cc> wrote:

> While implementing support for MACVLAN_FLAG_NOPROMISC, I realized how similar
> iplink_macvlan.c and iplink_macvtap.c are and that the main differences (apart
> from substituting "macvlan" for "macvtap") were fixes and enhancements which
> weren't applied to both files. To prevent this in the future and to share
> common code, this series merges the files. In addition, it implements support
> for MACVLAN_FLAG_NOPROMISC and finally documents these interface types in
> ip-link.8.in.
> 
> Phil Sutter (3):
>   ip: link: consolidate macvlan and macvtap
>   ip: macvlan: support MACVLAN_FLAG_NOPROMISC flag
>   man: ip-link: document MACVLAN/MACVTAP interface types
> 
>  ip/Makefile           |   2 +-
>  ip/iplink_macvlan.c   |  68 ++++++++++++++++++++++++--------
>  ip/iplink_macvtap.c   | 105 --------------------------------------------------
>  man/man8/ip-link.8.in |  50 ++++++++++++++++++++++++
>  4 files changed, 104 insertions(+), 121 deletions(-)
>  delete mode 100644 ip/iplink_macvtap.c
> 

Looks good applied. Always love to see more code deleted..
