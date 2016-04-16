From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Do not fix up linklocal and loopback addresses
Date: Sat, 16 Apr 2016 12:26:50 -0600
Message-ID: <571283EA.6020307@cumulusnetworks.com>
References: <5711AA52.6010400@brocade.com> <5711ADD1.2030904@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Mike Manning <mmanning@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35507 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbcDPS04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 14:26:56 -0400
Received: by mail-ig0-f172.google.com with SMTP id gy3so43725631igb.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 11:26:56 -0700 (PDT)
In-Reply-To: <5711ADD1.2030904@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/16 9:13 PM, Mike Manning wrote:
> f1705ec197e7 added the option to retain user configured addresses on an
> admin down. A comment to one of the later revisions suggested using the
> IFA_F_PERMANENT flag rather than adding a user_managed boolean to the
> ifaddr struct. A side effect of this change is that link local and
> loopback addresses are also retained which is not part of the objective
> of f1705ec197e7. Add check so that these addresses are not fixed up,
> given that a related fix 70af921db6f8 ensures that they are not kept in
> the first place, otherwise this incorrect fixup triggers a crash in fib6.

oops in fib6_del?

>
> Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")
> Signed-off-by: Mike Manning <mmanning@brocade.com>
> ---

for the change
Acked-by: David Ahern <dsa@cumulusnetworks.com>
