From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Mon, 18 Apr 2016 08:39:21 -0600
Message-ID: <5714F199.7020608@cumulusnetworks.com>
References: <5711ADD1.2030904@brocade.com> <5714EDDB.8080306@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:34360 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbcDROjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 10:39:32 -0400
Received: by mail-ig0-f176.google.com with SMTP id gy3so15558754igb.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 07:39:31 -0700 (PDT)
In-Reply-To: <5714EDDB.8080306@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16 8:23 AM, Mike Manning wrote:
> f1705ec197e7 "Make address flushing on ifdown optional" added the option
> to retain user configured addresses on an admin down. A comment to one of
> the later revisions suggested using the IFA_F_PERMANENT flag rather than
> adding a user_managed boolean to the ifaddr struct. A side effect of this
> change is that link local and loopback addresses were also retained which
> was not part of the objective of the original changes. The fix 70af921db6f8
> "Do not keep linklocal and loopback addresses" ensures that these are no
> longer kept. Similarly, the present fix ensures that these addresses are not
> fixed up either, otherwise the incorrect fixup triggers a crash in fib6.
>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---
>   net/ipv6/addrconf.c |   13 +++++++------
>   1 file changed, 7 insertions(+), 6 deletions(-)

Is this a v2? Code change is the same.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
