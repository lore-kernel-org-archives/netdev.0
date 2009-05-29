From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 5/5] netdev: bfin_mac: fix crash when
	unloading module
Date: Fri, 29 May 2009 07:47:32 -0400
Message-ID: <8bd0f97a0905290447u22c613dfua7efb190c8942b60@mail.gmail.com>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	 <1243404615-25879-6-git-send-email-vapier@gentoo.org>
	 <20090529.021042.184273147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f166.google.com ([209.85.217.166]:52126 "EHLO
	mail-gx0-f166.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757990AbZE2Lrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:47:31 -0400
Received: by gxk10 with SMTP id 10so10279086gxk.13
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 04:47:32 -0700 (PDT)
In-Reply-To: <20090529.021042.184273147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 05:10, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
>> If we build the Blackfin EMAC driver as a module and then unload it at
>> runtime, it would cause a crash:
>> root:/> rmmod bfin_mac
>
> Actually, I reverted patch #4.
>
> This bug is caused by patch #4, integrate this bug fix into
> patch #4 and resubmit as one whole change.

will do, thanks
-mike
