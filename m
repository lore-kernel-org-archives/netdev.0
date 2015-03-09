From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: destroy proto tp when all filters
 are gone
Date: Mon, 09 Mar 2015 09:43:26 -0400
Message-ID: <54FDA37E.5090603@mojatatu.com>
References: <1425671279-25399-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:46001 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbbCINnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 09:43:37 -0400
Received: by iecrd18 with SMTP id rd18so12291818iec.12
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 06:43:36 -0700 (PDT)
In-Reply-To: <1425671279-25399-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/15 14:47, Cong Wang wrote:
> From: Cong Wang<cwang@twopensource.com>
>
> Kernel automatically creates a tp for each
> (kind, protocol, priority) tuple, which has handle 0,
> when we add a new filter, but it still is left there
> after we remove our own, unless we don't specify the
> handle (literally means all the filters under
> the tuple). For example this one is left:
>
>    # tc filter show dev eth0
>    filter parent 8001: protocol arp pref 49152 basic
>
> The user-space is hard to clean up these for kernel
> because filters like u32 are organized in a complex way.
> So kernel is responsible to remove it after all filters
> are gone.  Each type of filter has its own way to
> store the filters, so each type has to provide its
> way to check if all filters are gone.
>
> Cc: Jamal Hadi Salim<jhs@mojatatu.com>
> Signed-off-by: Cong Wang<cwang@twopensource.com>
> Signed-off-by: Cong Wang<xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim<jhs@mojatatu.com>


cheers,
jamal
