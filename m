From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/4] vrf: a few simplifications and cleanups
Date: Tue, 18 Aug 2015 13:38:23 -0600
Message-ID: <55D389AF.1010403@cumulusnetworks.com>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34282 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbHRTiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:38:24 -0400
Received: by iodb91 with SMTP id b91so201318631iod.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:38:24 -0700 (PDT)
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 11:28 AM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Hi,
> These patches remove some unnecessary checks (patches 3, 4), unnecessary
> num_slaves member and refcnt manipulations which are already done by the
> upper functions.
>
> Cheers,
>   Nik
>
> Nikolay Aleksandrov (4):
>    vrf: drop unnecessary dev refcnt changes
>    vrf: drop unused num_slaves member
>    vrf: don't check for dstats and rth in uninit path
>    vrf: simplify the netdev notifier function
>
>   drivers/net/vrf.c | 15 ++++-----------
>   include/net/vrf.h |  1 -
>   2 files changed, 4 insertions(+), 12 deletions(-)
>

Looks good to me. Thanks, Nikolay.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
