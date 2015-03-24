From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH for kernel 3.4.x 0/1] net: neighbour: Add mcast_resolicit
 to configure the number of multicast resolicitations in PROBE state
Date: Tue, 24 Mar 2015 20:06:43 +0900
Message-ID: <55114543.2080709@miraclelinux.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Zhu Yanjun <Yanjun.Zhu@windriver.com>, lizefan@huawei.com,
	netdev@vger.kernel.org, ulf.samuelsson@ericsson.com,
	yoshfuji@linux-ipv6.org, Alexandre.Dietsch@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og119.obsmtp.com ([64.18.2.16]:47361 "HELO
	exprod7og119.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751814AbbCXLGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 07:06:48 -0400
Received: by mail-pd0-f176.google.com with SMTP id c3so218163187pdn.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 04:06:47 -0700 (PDT)
In-Reply-To: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Zhu Yanjun wrote:
> This patch is for the kernel 4.0. But kernel 3.4 needs this patch, too. So this patch is backported.
> There are the following modifications:
>  1. Because the mothod to set sysctl is different between kernel 3.4 and kernel 4.0, in this patch, the sysctl method is changed;
>  2. Because the variables of mcast_resolicit is different, in this patch, the function neigh_max_probes is changed;
>  3. Because there are so many modifications in this patch, so the author is changed to me;
> 
> Zhu Yanjun (1):
>   net: neighbour: Add mcast_resolicit to configure the number of
>     multicast resolicitations in PROBE state
> 
>  include/linux/neighbour.h |  1 +
>  include/net/neighbour.h   |  1 +
>  net/core/neighbour.c      | 20 +++++++++++++++++---
>  3 files changed, 19 insertions(+), 3 deletions(-)
> 

Hmm, it needs additional knob to change this 10+-year-old
behavior.  I am not for backporting this to old stable
kernels unless all stable kernels supports this knob as
well.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
