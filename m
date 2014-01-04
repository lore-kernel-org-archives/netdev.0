From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: unify the pcpu_tstats and br_cpu_netstats
Date: Fri, 3 Jan 2014 16:43:37 -0800
Message-ID: <CAM_iQpUNgwUioWxDXe2DAhVFo0gvPudM1-_CXiNG2rZCnzLTag@mail.gmail.com>
References: <1388653054-4341-1-git-send-email-roy.qing.li@gmail.com>
	<slrnlccgj7.3uh.xiyou.wangcong@linux-6brj.site>
	<20140103.193253.2226162174184357030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:62384 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaADAni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:43:38 -0500
Received: by mail-oa0-f47.google.com with SMTP id k1so16675254oag.20
        for <netdev@vger.kernel.org>; Fri, 03 Jan 2014 16:43:38 -0800 (PST)
In-Reply-To: <20140103.193253.2226162174184357030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 3, 2014 at 4:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Fri, 3 Jan 2014 04:53:47 +0000 (UTC)
>
>> On Thu, 02 Jan 2014 at 08:57 GMT, roy.qing.li@gmail.com <roy.qing.li@gmail.com> wrote:
>>> From: Li RongQing <roy.qing.li@gmail.com>
>>>
>>> They are same, so unify them as one, pcpu_tstats.
>>> and move pcpu_tstat into netdevice.h
>>>
>>
>> tstats means Tunnel STATS, right? So, it has to be
>> in if_tunnel.h.
>
> They are being used in the bridging code now, did you read the
> patch?
>
> So not really limited to just tunnels, and therefore they really do
> belong somewhere generic like netdevice.h

I knew, my point is we should find a better name than "tstat".

>
> This also means that since they are now an encapsulation thing we
> should rename them to pcpu_encap_stats or similar, thanks.

Not sure "encap" makes sense for bridge too.

Thanks.
