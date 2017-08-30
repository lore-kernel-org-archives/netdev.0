From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/3] tc: act_ife: handle IEEE IFE ethertype as
 default
Date: Wed, 30 Aug 2017 08:27:32 -0700
Message-ID: <20170830082732.365864e3@xeon-e3>
References: <20170828190315.26646-1-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, yotamg@mellanox.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, lucasb@mojatatu.com, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36376 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdH3P1e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 11:27:34 -0400
Received: by mail-pg0-f45.google.com with SMTP id r133so20775833pgr.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 08:27:34 -0700 (PDT)
In-Reply-To: <20170828190315.26646-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 15:03:12 -0400
Alexander Aring <aring@mojatatu.com> wrote:

> Hi,
> 
> this patch series will introduce the IFE ethertype which is registered by
> IEEE. If the netlink act_ife type netlink attribute is not given it will
> use this value by default now.
> At least it will introduce some UAPI testcases to check if the default type
> is used if not specified and vice versa.
> 
> - Alex
> 
> Alexander Aring (3):
>   if_ether: add forces ife lfb type
>   act_ife: use registered ife_type as fallback
>   tc-testing: add test for testing ife type
> 
>  include/uapi/linux/if_ether.h                      |  1 +
>  net/sched/act_ife.c                                | 17 ++------
>  .../tc-testing/tc-tests/actions/tests.json         | 50 ++++++++++++++++++++++
>  3 files changed, 54 insertions(+), 14 deletions(-)
> 

Applied to net-next
