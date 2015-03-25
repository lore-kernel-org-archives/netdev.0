From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH for kernel 3.4.x 0/1] net: neighbour: Add mcast_resolicit
 to configure the number of multicast resolicitations in PROBE state
Date: Wed, 25 Mar 2015 10:24:31 +0800
Message-ID: <55121C5F.4050202@windriver.com>
References: <1427190355-1216-1-git-send-email-Yanjun.Zhu@windriver.com> <55114543.2080709@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<ulf.samuelsson@ericsson.com>, <yoshfuji@linux-ipv6.org>,
	<Alexandre.Dietsch@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33111 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbCYCY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 22:24:28 -0400
In-Reply-To: <55114543.2080709@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2015 07:06 PM, YOSHIFUJI Hideaki wrote:
> Hi,
>
> Zhu Yanjun wrote:
>> This patch is for the kernel 4.0. But kernel 3.4 needs this patch, too. So this patch is backported.
>> There are the following modifications:
>>  1. Because the mothod to set sysctl is different between kernel 3.4 and kernel 4.0, in this patch, the sysctl method is changed;
>>  2. Because the variables of mcast_resolicit is different, in this patch, the function neigh_max_probes is changed;
>>  3. Because there are so many modifications in this patch, so the author is changed to me;
>>
>> Zhu Yanjun (1):
>>   net: neighbour: Add mcast_resolicit to configure the number of
>>     multicast resolicitations in PROBE state
>>
>>  include/linux/neighbour.h |  1 +
>>  include/net/neighbour.h   |  1 +
>>  net/core/neighbour.c      | 20 +++++++++++++++++---
>>  3 files changed, 19 insertions(+), 3 deletions(-)
>>
> Hmm, it needs additional knob to change this 10+-year-old
> behavior.  I am not for backporting this to old stable
> kernels unless all stable kernels supports this knob as
> well.
>
HI, YOSHIFUJI

>From your perspective, what is the additional knob ? would you like to
let me know?

Best Regards!
Zhu Yanjun
