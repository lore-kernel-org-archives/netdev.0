From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/4] vrf: cleanups part 2
Date: Wed, 19 Aug 2015 10:47:10 -0700
Message-ID: <55D4C11E.5000300@cumulusnetworks.com>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shm@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34632 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbbHSRrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 13:47:12 -0400
Received: by paccq16 with SMTP id cq16so7801155pac.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 10:47:11 -0700 (PDT)
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 8:27 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
> Hi,
> This is the next part of vrf cleanups, patch 1 drops the SLAB_PANIC when
> creating kmem cache since it's handled, patch 02 removes a slave duplicate
> check which is already done by the lower/upper code, patch 3 moves the
> ndo_add_slave code around a bit so we can drop an error label and patch 4
> drops the master device checks which are unnecessary because the ops are
> taken from the master device itself so it can't be different.
>
> Cheers,
>   Nik
>
> Nikolay Aleksandrov (4):
>    vrf: don't panic on cache create failure
>    vrf: remove unnecessary duplicate check
>    vrf: move vrf_insert_slave so we can drop a goto label
>    vrf: ndo_add|del_slave drop unnecessary checks
>
>   drivers/net/vrf.c | 24 ++++--------------------
>   1 file changed, 4 insertions(+), 20 deletions(-)
>

Looks good to me. Thanks, Nikolay.

Acked-by: David Ahern <dsa@cumulusnetworks.com>
