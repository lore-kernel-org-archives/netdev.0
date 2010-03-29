From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re [RFC PATCH 1/2] iproute2: Add libnl support.
Date: Mon, 29 Mar 2010 14:06:42 -0700
Message-ID: <20100329140642.7305bdfc@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <chapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39319 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab0C2VJi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 17:09:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This patch links the ip utility with libnl, which must be separately
> installed. This lets new functionality use libnl to implement its
> netlink interfaces.
> 
> Package developers will need to add libnl to the iproute2 package
> dependencies.
> ---
>  Makefile |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

No. I don't want to make iproute2 dependent on libnl.
It doesn't make sense to have dependency without major need for new
functionality.  There are already netlink library routines in iproute2

