From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v3] ipv6: Kill ipv6 dependency of icmpv6_send().
Date: Mon, 29 Apr 2013 10:44:45 -0700
Message-ID: <CALnjE+pTekHaz760QQ-t2dbcvGkAf-sG5T9sj_iD3S4C-zgxFQ@mail.gmail.com>
References: <1366924110-3397-1-git-send-email-pshelar@nicira.com>
	<klkjcu$drc$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:35989 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758399Ab3D2Ror (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 13:44:47 -0400
Received: by mail-qe0-f72.google.com with SMTP id 9so8208775qea.3
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 10:44:46 -0700 (PDT)
In-Reply-To: <klkjcu$drc$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 28, 2013 at 6:46 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, 25 Apr 2013 at 21:08 GMT, Pravin B Shelar <pshelar@nicira.com> wrote:
>> diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
>> new file mode 100644
>> index 0000000..4578e23
>> --- /dev/null
>> +++ b/net/ipv6/ip6_icmp.c
>> @@ -0,0 +1,47 @@
>> +#include <linux/export.h>
>> +#include <linux/icmpv6.h>
>> +#include <linux/mutex.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/spinlock.h>
>> +
>> +#include <net/ipv6.h>
>> +
>> +#if IS_ENABLED(CONFIG_IPV6)
>> +
>
> I don't think we need #if IS_ENABLED(CONFIG_IPV6) inside
> net/ipv6/ip6_icmp.c.
>
This file is statically linked to kernel, So it needs this check to
avoid compilation errors.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
