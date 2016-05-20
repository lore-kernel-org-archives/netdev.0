From: Tom Herbert <tom@herbertland.com>
Subject: IPv6 extension header privileges
Date: Fri, 20 May 2016 15:37:32 -0700
Message-ID: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36962 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbcETWhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 18:37:33 -0400
Received: by mail-ig0-f176.google.com with SMTP id l10so1023705igk.0
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 15:37:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In ipv6_sockglue.c I noticed:

/* hop-by-hop / destination options are privileged option */
retv = -EPERM;
if (optname != IPV6_RTHDR && !ns_capable(net->user_ns, CAP_NET_RAW))
           break;

Can anyone provide that rationale as to why these are privileged ops?

Thanks,
Tom
