From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] netfilter: nfnetlink_queue: Unregister pernet subsys in
 case of init failure
Date: Mon, 7 Dec 2015 15:29:25 +0300
Message-ID: <56657BA5.6070303@cogentembedded.com>
References: <1449483206-22618-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Nikolay Borisov <kernel@kyup.com>, fruggeri@arista.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1449483206-22618-1-git-send-email-kernel@kyup.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/07/2015 01:13 PM, Nikolay Borisov wrote:

> Commit 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}:

    Double quotes please, that's what scripts/checkpatch.pl enforces now.

> Register pernet in first place') reorganised the initialisation
> order of the pernet_subsys to avoid "use-before-initialised"
> condition. However, in doing so the cleanup logic in nfnetlink_queue
> got botched in that the pernet_subsys wasn't cleaned in case
> nfnetlink_subsys_register failed. This patch adds the necessary
> cleanup routine call.
>
> Fixes: 3bfe049807c2403 ('netfilter: nfnetlink_{log,queue}: Register
> 						pernet in first place')

    Likewise.

>
> Signed-off-by: Nikolay Borisov <kernel@kyup.com>

[...]

MBR, Sergei

