From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drop_monitor: Update netlink protocol to include
 netlink attribute header in alert message
Date: Mon, 27 Apr 2009 03:17:46 -0700 (PDT)
Message-ID: <20090427.031746.166472203.davem@davemloft.net>
References: <20090423200548.GE30405@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbZD0KRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 06:17:53 -0400
In-Reply-To: <20090423200548.GE30405@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu, 23 Apr 2009 16:05:48 -0400

> When I initially implemented this protocol, I disregarded the use of netlink
> attribute headers, thinking for my purposes they weren't needed.  I've come to
> find out that, as I'm starting to work with sending down messages with
> associated data (like config messages), the kernel code spits out warnings about
> trailing data in a netlink skb that doesn't have an associated header on it.  As
> such, I'm going to start including attribute headers in my netlink transaction,
> and so for completeness, I should likely include them on messages bound from the
> kernel to user space.  This patch adds that header to the kernel, and bumps the
> protocol version accordingly
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next-2.6, thanks Neil.
