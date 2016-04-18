From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Mon, 18 Apr 2016 18:19:59 +0300
Message-ID: <5714FB1F.5040200@cogentembedded.com>
References: <5711ADD1.2030904@brocade.com> <5714EDDB.8080306@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34525 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbcDRPUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 11:20:01 -0400
Received: by mail-lf0-f54.google.com with SMTP id j11so220651032lfb.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 08:20:00 -0700 (PDT)
In-Reply-To: <5714EDDB.8080306@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/18/2016 5:23 PM, Mike Manning wrote:

> f1705ec197e7 "Make address flushing on ifdown optional" added the option

    Looking further, this doesn't seem like a complete commit summary. And you 
need to enclose it in parens too.

> to retain user configured addresses on an admin down. A comment to one of
> the later revisions suggested using the IFA_F_PERMANENT flag rather than
> adding a user_managed boolean to the ifaddr struct. A side effect of this
> change is that link local and loopback addresses were also retained which
> was not part of the objective of the original changes. The fix 70af921db6f8
> "Do not keep linklocal and loopback addresses" ensures that these are no

    Again, () are needed around the summary.

> longer kept. Similarly, the present fix ensures that these addresses are not
> fixed up either, otherwise the incorrect fixup triggers a crash in fib6.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
[...]

MBR, Sergei
