From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: fix hello and hold timers
 starting/stopping
Date: Fri, 19 May 2017 23:12:45 +0300
Message-ID: <6c14d4a9-0fc8-aa28-7c73-99ad5e0fbef5@cumulusnetworks.com>
References: <20170519173043.10201-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        lucien.xin@gmail.com
To: Ivan Vecera <cera@cera.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36891 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756379AbdESUMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:12:49 -0400
Received: by mail-wm0-f46.google.com with SMTP id d127so95468727wmf.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 13:12:48 -0700 (PDT)
In-Reply-To: <20170519173043.10201-1-cera@cera.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 8:30 PM, Ivan Vecera wrote:
> Current bridge code incorrectly handles starting/stopping of hello and
> hold timers during STP enable/disable.
> 
> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>     transition. The timers are already stopped in NO_STP state so
>     this is confusing no-op.
> 
> 2. During USER_STP->NO_STP transition the timers are started. This
>     does not make sense and is confusion because the timer should not be
>     active in NO_STP state.
> 
> Cc: davem@davemloft.net
> Cc: sashok@cumulusnetworks.com
> Cc: stephen@networkplumber.org
> Cc: bridge@lists.linux-foundation.org
> Cc: lucien.xin@gmail.com
> Cc: nikolay@cumulusnetworks.com
> Signed-off-by: Ivan Vecera <cera@cera.cz>
> ---
>   net/bridge/br_stp_if.c | 11 -----------
>   1 file changed, 11 deletions(-)
> 

LGTM, thanks!

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
