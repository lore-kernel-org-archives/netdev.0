From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next v2] neigh: remove dynamic neigh table
 registration support
Date: Tue, 4 Nov 2014 16:38:55 -0800
Message-ID: <CAM_iQpU_YM55J_-dphou9qN+ROJwAhUh3im81t8iNfwTeAnj3w@mail.gmail.com>
References: <1415038454-8150-1-git-send-email-xiyou.wangcong@gmail.com>
	<20141104.170251.950859328398615616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:41521 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaKEAi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 19:38:56 -0500
Received: by mail-ob0-f182.google.com with SMTP id nt9so13190184obb.27
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 16:38:55 -0800 (PST)
In-Reply-To: <20141104.170251.950859328398615616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 4, 2014 at 2:02 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Mon,  3 Nov 2014 10:14:14 -0800
>
>> Currently there are only three neigh tables in the whole kernel:
>> arp table, ndisc table and decnet neigh table. What's more,
>> we don't support registering multiple tables per family.
>> Therefore we can just make these tables statically built-in.
>>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>> v2: remove useless #ifdef's
>>     move the assignment to the end of neigh_table_init()
>
> neigh_table_clear should definitely NULL out the slot, otherwise
> we hold in there a pointer to module memory which is about to
> be released.

Good catch! I totally missed neigh_table_clear().

Thanks!
