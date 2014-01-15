From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] net_sched: act: remove headers in include/net/tc_act/
Date: Wed, 15 Jan 2014 10:57:10 -0800
Message-ID: <CAHA+R7OEZjKMgbbtoAavi88C1HVYvTKTrDgGJC2uAjsznB1CwQ@mail.gmail.com>
References: <1389747699-32508-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140114.181213.695613248997119103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:55022 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaAOS5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 13:57:12 -0500
Received: by mail-lb0-f181.google.com with SMTP id z5so1147339lbh.12
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 10:57:10 -0800 (PST)
In-Reply-To: <20140114.181213.695613248997119103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 14, 2014 at 6:12 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue, 14 Jan 2014 17:01:39 -0800
>
>> These headers are not necessary because those definitions in them
>> are action specific and are not shared for others. Just move them
>> into the C files.
>>
>> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Like Eric, I think this is a dubious change.
>
> There is nothing wrong with using these headers to define the
> core data structures used by each of these actions modules.
>

Nothing is wrong here, just that it is not necessary.

act_police defines similar stuffs in its C file, not a header.
I don't see any reason why others can't.
