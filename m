From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH IPROUTE2] ss: Add support for sk_meminfo_backlog
Date: Thu, 07 Jun 2012 07:32:48 +0200
Message-ID: <1339047168.26966.83.camel@edumazet-glaptop>
References: <1339024292-4361-1-git-send-email-subramanian.vijay@gmail.com>
	 <1339042844.26966.75.camel@edumazet-glaptop>
	 <CAGK4HS9pZmbkEHtu_e71_XxQ6RpSVc3tES6=z4WiGrMW45z_EA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57164 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661Ab2FGFcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 01:32:54 -0400
Received: by eaak11 with SMTP id k11so56409eaa.19
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2012 22:32:53 -0700 (PDT)
In-Reply-To: <CAGK4HS9pZmbkEHtu_e71_XxQ6RpSVc3tES6=z4WiGrMW45z_EA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 22:18 -0700, Vijay Subramanian wrote:
> > This is not the right way to handle this.
> >
> > I already have a patch and was waiting the appropriate time to submit
> > it.
> >
> Thanks. I will wait for your patch to see what I missed.
> 
> Vijay

Well, the trick is that we must support previous kernels (3.5 for
example), so should not display backlog info on them.

I'll send the patch, dont worry ;)
