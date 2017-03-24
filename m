From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 11:15:25 +0100
Message-ID: <20170324101525.5i26wlg5jbsp6qrh@nataraja>
References: <20170324093358.31374-1-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:59360 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933468AbdCXKtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 06:49:50 -0400
Content-Disposition: inline
In-Reply-To: <20170324093358.31374-1-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jonas,

looks fine to me, but I haven't tested it.  Did you manually test it
using the extended libgtpnl + tools?

Also, in code like this:

+       if (gtp->role == GTP_ROLE_SGSN) {
+               pctx = ipv4_pdp_find(gtp, iph->saddr);
+       } else {

I think general Linux kernel coding style is to not have curly-brackets
around single-line blocks. See "Do not unnecessarily use braces where a
single statement will do." in line 169 of
Documentation/process/coding-style.rst

I won't mind your current style, and it is not a blocker issue to me,
but still it would be nice for general consistency.

Acked-by: Harald Welte <laforge@gnumonks.org>

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
