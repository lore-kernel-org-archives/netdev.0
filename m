From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: fix several warnings emitted by clang
 scan-build
Date: Wed, 31 Aug 2011 12:20:06 -0700
Message-ID: <20110831122006.52c958dd@nehalam.ftrdhcpuser.net>
References: <1310759966-10465-1-git-send-email-dan@archlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan McGee <dan@archlinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43925 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847Ab1HaTT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 15:19:57 -0400
In-Reply-To: <1310759966-10465-1-git-send-email-dan@archlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2011 14:59:26 -0500
Dan McGee <dan@archlinux.org> wrote:

> * genl/genl.c: remove unused basename logic, avoid dereference of
>   possibly NULL variable
> * ip/iptuntap.c: avoid double open and leak of file handle
> * misc/arpd.c: zero out socklen structure
> * misc/{ifstat,nstat,rtacct}.c: ensure uptime is initialized if
>   /proc/uptime cannot be opened
> * tc/m_xt.c: only unset fields if m is non-NULL
> 
> Signed-off-by: Dan McGee <dan@archlinux.org>

All but arpd applied. The arpd change is unnecessary since the
socket structure is in recvfrom() call it will be set by kernel.
