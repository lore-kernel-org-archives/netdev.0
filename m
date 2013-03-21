From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/4] ss: Get netlink sockets info via sock-diag
Date: Thu, 21 Mar 2013 10:00:25 -0700
Message-ID: <20130321100025.619edf3d@nehalam.linuxnetplumber.net>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
	<1363858406-1489-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:41692 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756149Ab3CURAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 13:00:33 -0400
Received: by mail-da0-f42.google.com with SMTP id n15so1752545dad.29
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 10:00:33 -0700 (PDT)
In-Reply-To: <1363858406-1489-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Mar 2013 13:33:22 +0400
Andrey Vagin <avagin@openvz.org> wrote:

> Cc: Stephen Hemminger <stephen@networkplumber.org>
> 
> Andrey Vagin (4):
>   ss: handle socket diag request in a separate function
>   ss: create a frunction to print info about netlink sockets
>   ss: show destination address for netlink sockets
>   ss: Get netlink sockets info via sock-diag
> 
>  include/linux/netlink_diag.h |  40 ++++++++
>  misc/ss.c                    | 235 +++++++++++++++++++++++++++++--------------
>  2 files changed, 198 insertions(+), 77 deletions(-)
>  create mode 100644 include/linux/netlink_diag.h
> 

Since this depends on functionality not in the upstream kernel.
Resubmit this during the 3.10 merge window. At the start of the merge
window, headers are synchronized with the kernel headers.
