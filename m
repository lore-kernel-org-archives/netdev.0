From: Jonas Bonn <jonas@southpole.se>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 14:46:42 +0100
Message-ID: <64102031-a435-9ca0-9dca-ec60d335c0e2@southpole.se>
References: <20170324093358.31374-1-jonas@southpole.se>
 <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([37.247.8.11]:50613 "EHLO mail.southpole.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754323AbdCXNqw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 09:46:52 -0400
In-Reply-To: <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Harald,

On 03/24/2017 11:15 AM, Harald Welte wrote:
> Hi Jonas,
>
> looks fine to me, but I haven't tested it.  Did you manually test it
> using the extended libgtpnl + tools?

I have tested it against your libgtpnl branch laforge/sgsn-role. 
Creating an interface with tools/gtp-link works fine.

We have been running the v1 patches in a production load-testing system 
for the last month.  That all works and gives good performance.  I 
haven't been able to actually run the v2 and v3 patches in that 
environment as access to it is a bit limited... that said, the changes 
from v1 to v3 are really only cosmetic and don't even touch the "parts 
that matter" with respect to encapsulation. Really the patch is pretty 
trivial... mucking about with the netlink interface is the bulk of it 
and that bit has been tested and works.

>
> Also, in code like this:
> in
> +       if (gtp->role == GTP_ROLE_SGSN) {
> +               pctx = ipv4_pdp_find(gtp, iph->saddr);
> +       } else {
>
> I think general Linux kernel coding style is to not have curly-brackets
> around single-line blocks. See "Do not unnecessarily use braces where a
> single statement will do." in line 169 of
> Documentation/process/coding-style.rst
>
> I won't mind your current style, and it is not a blocker issue to me,
> but still it would be nice for general consistency.
OK, I'll fix that up just for the sake of correctness and send a v4.

>
> Acked-by: Harald Welte <laforge@gnumonks.org>
>
Thanks,

Jonas
