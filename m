From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 0/2] GTP SGSN-side tunnels
Date: Fri, 24 Mar 2017 14:59:23 +0300
Message-ID: <44b25d2b-ab46-98f3-8335-5e9cdb79ba65@cogentembedded.com>
References: <20170324093358.31374-1-jonas@southpole.se>
 <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: Harald Welte <laforge@gnumonks.org>,
        Jonas Bonn <jonas@southpole.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34581 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbdCXL72 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 07:59:28 -0400
Received: by mail-lf0-f45.google.com with SMTP id z15so59036lfd.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 04:59:26 -0700 (PDT)
In-Reply-To: <20170324101525.5i26wlg5jbsp6qrh@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2017 01:15 PM, Harald Welte wrote:

> looks fine to me, but I haven't tested it.  Did you manually test it
> using the extended libgtpnl + tools?
>
> Also, in code like this:
>
> +       if (gtp->role == GTP_ROLE_SGSN) {
> +               pctx = ipv4_pdp_find(gtp, iph->saddr);
> +       } else {
>
> I think general Linux kernel coding style is to not have curly-brackets
> around single-line blocks. See "Do not unnecessarily use braces where a
> single statement will do." in line 169 of
> Documentation/process/coding-style.rst

    See line 191 in the same file for the exception. :-)

[...]

MBR, Sergei
