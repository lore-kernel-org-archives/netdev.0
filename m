From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: define SOL_PPPOL2TP in uapi
Date: Thu, 06 Apr 2017 13:25:34 -0700 (PDT)
Message-ID: <20170406.132534.1383136932861851088.davem@davemloft.net>
References: <28884134c7944f005e4872256742b10765cc2770.1491402366.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752296AbdDFUZl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:25:41 -0400
In-Reply-To: <28884134c7944f005e4872256742b10765cc2770.1491402366.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 5 Apr 2017 16:52:35 +0200

> Userspace needs SOL_PPPOL2TP to be defined for using PPPOL2TP_SO_*
> socket options.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

We really can't do this, there is no precedence for defining the SOL_*
values in the kernel headers, it needs to come from the libc headers just
like the other SOL_* values do for applications.

Thank you.
