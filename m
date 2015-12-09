From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: Re: [net-next,1/2] net: Set sk_txhash from a random number
Date: Wed, 9 Dec 2015 14:14:10 +0300
Message-ID: <56680D02.6080403@gmail.com>
References: <1438124526-2129341-2-git-send-email-tom@herbertland.com>
 <566695D6.6060603@gmail.com>
 <1449580559.7632.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S36u4=1f2WAPhgG_t9oxZSK75uR_hK28=HR_2FibUN9amQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35465 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbLILOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 06:14:17 -0500
Received: by lbpu9 with SMTP id u9so27688096lbp.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 03:14:15 -0800 (PST)
In-Reply-To: <CALx6S36u4=1f2WAPhgG_t9oxZSK75uR_hK28=HR_2FibUN9amQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

08.12.2015 19:33, Tom Herbert wrote:
> On Tue, Dec 8, 2015 at 5:15 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> There never has been such guarantee. Even rx hashes for a single TCP
>> flow can differ, if packets are received on two different NIC with
>> different RSSS keys.
>>
> +1, it is a salient property that hashes can differ in each direction
> for a flow and that the hash for a flow can change over time.
Thanks! I'll then try to move onto BPF fanout.
