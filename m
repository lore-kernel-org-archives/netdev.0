From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] l2tp: define SOL_PPPOL2TP in uapi
Date: Fri, 7 Apr 2017 09:48:41 +0200
Message-ID: <20170407074841.do4ekkgangsuz6w2@alphalink.fr>
References: <28884134c7944f005e4872256742b10765cc2770.1491402366.git.g.nault@alphalink.fr>
 <20170406.132534.1383136932861851088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:33071 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753479AbdDGHsw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:48:52 -0400
Content-Disposition: inline
In-Reply-To: <20170406.132534.1383136932861851088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 06, 2017 at 01:25:34PM -0700, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Wed, 5 Apr 2017 16:52:35 +0200
> 
> > Userspace needs SOL_PPPOL2TP to be defined for using PPPOL2TP_SO_*
> > socket options.
> > 
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> 
> We really can't do this, there is no precedence for defining the SOL_*
> values in the kernel headers, it needs to come from the libc headers just
> like the other SOL_* values do for applications.
> 
Got it, thanks.
