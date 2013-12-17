From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: netfilter: active obj WARN when cleaning up
Date: Tue, 17 Dec 2013 17:09:08 -0500
Message-ID: <52B0CB84.9050907@oracle.com>
References: <20131127233415.GB19270@kroah.com> <00000142b4282aaf-913f5e4c-314c-4351-9d24-615e66928157-000000@email.amazonses.com> <20131202164039.GA19937@kroah.com> <00000142b4514eb5-2e8f675d-0ecc-423b-9906-58c5f383089b-000000@email.amazonses.com> <20131202172615.GA4722@kroah.com> <00000142b4aeca89-186fc179-92b8-492f-956c-38a7c196d187-000000@email.amazonses.com> <20131202190814.GA2267@kroah.com> <00000142b4d4360c-5755af87-b9b0-4847-b5fa-7a9dd13b49c5-000000@email.amazonses.com> <20131202212235.GA1297@kroah.com> <00000142b54f6694-c51e81b1-f1a2-483b-a1ce-a2d4cb6b155c-000000@email.amazonses.com> <20131202222208.GB13034@kroah.com> <00000142b90da700-19f6b465-ff15-4b2b-9bcd-b91d71958b7f-000000@email.amazonses.com> <52B0ABB6.8090205@oracle.com> <000001430246e902-112cfb9d-5393-4eed-8529-e0008f88df4
 5-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Thomas Gleixner <tglx@linutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <000001430246e902-112cfb9d-5393-4eed-8529-e0008f88df45-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 12/17/2013 03:37 PM, Christoph Lameter wrote:
> On Tue, 17 Dec 2013, Sasha Levin wrote:
>
>> I'm still seeing warnings with this patch applied:
>
> Looks like this is related to some device release mechanism that frees
> twice?
>
> I do not see any kmem_cache management functions in the backtrace and
> therefore would guess that this is not the same issue.

rgr, sorry about that - I grepped for 'timer_list' which seemed to have been in
all previous kmem_cache spews and thought this one is related.

If that's not the case, your patch works for me.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
