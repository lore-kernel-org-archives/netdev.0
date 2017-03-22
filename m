From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] netvsc: performance regressions in
 net-next
Date: Wed, 22 Mar 2017 11:23:08 -0700 (PDT)
Message-ID: <20170322.112308.620319558265849393.davem@davemloft.net>
References: <20170320202805.19362-1-sthemmin@microsoft.com>
        <20170320133152.52a7da53@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42642 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965466AbdCVSXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:23:10 -0400
In-Reply-To: <20170320133152.52a7da53@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 20 Mar 2017 13:31:52 -0700

> On Mon, 20 Mar 2017 13:28:03 -0700
> Stephen Hemminger <stephen@networkplumber.org> wrote:
> 
>> Fix for performance regression introduced with NAPI change;
>> and followup cleanup of vmbus core code.
>> 
>> Stephen Hemminger (2):
>>   netvsc: fix NAPI performance regression
>>   vmbus: no longer expose iterator internals
>> 
>>  drivers/hv/ring_buffer.c        | 51 +++++++++++++++++++++--------------------
>>  drivers/net/hyperv/hyperv_net.h |  1 +
>>  drivers/net/hyperv/netvsc.c     | 41 +++++++++++++++------------------
>>  include/linux/hyperv.h          | 22 +-----------------
>>  4 files changed, 46 insertions(+), 69 deletions(-)
>> 
> 
> Drop this version.  The code is correct the second patch causes
> clashes with some later patches. Will resend.

Oh, ok, good thing I saw this before pushing out.

Reverted.
