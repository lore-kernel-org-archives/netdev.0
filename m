From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netlink_route kernel data dump size increased
Date: Wed, 19 Aug 2015 14:17:27 -0700
Message-ID: <1440019047.6610.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAM1L+iBqypLJi2qD3Ncs_L+Lyi=ozRSciZvhBL5OzqjPFGfprg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: tej parkash <parkash.tej@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33037 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbbHSVR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 17:17:29 -0400
Received: by padfo6 with SMTP id fo6so5070810pad.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 14:17:28 -0700 (PDT)
In-Reply-To: <CAM1L+iBqypLJi2qD3Ncs_L+Lyi=ozRSciZvhBL5OzqjPFGfprg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 23:41 +0530, tej parkash wrote:
> All,
> 
> We are running application on Linux Kernel 3.10 to collect network
> interface information using  NETLINK_ROUTE protocol. earlier (kernel
> 2.6.32) we were having 8K buffer allocated to collect all data but
> with new kernel (3.10) we are seeing read socket error, as buffer size
> is not sufficient for all network dump data.
> 
> We want to understand that if the userspace buffer limit increased to
> 16K or we need some other mechanism to collect the data in 8K chuck.
> or Is there any other way application can use NETLINK_ROUTE  protocol,
> so that it will not break the application if data size gets increased
> in future.
> 
> I did some some browsing and found some link but they were not very conclusive.
> http://www.spinics.net/lists/netdev/msg162185.html
> 
> Appreciate for any kind of help or pointers here
> 

This sounds like a bug that might have been fixed later.

User space is not required to switch to 16KB, although it is recommended
to reduce number of syscalls.
