From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: avoid disabling irq for netns id
Date: Wed, 30 Nov 2016 16:12:43 -0500 (EST)
Message-ID: <20161130.161243.1093910043528839130.davem@davemloft.net>
References: <148045748887.22539.3188295553967836703.stgit@sifl>
	<20161130.145822.727604546507312208.davem@davemloft.net>
	<CAGH-Kgv0UpmDdaW=z8pa1VvmrcJeaA57uMneqNEgex6Xa8NSQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, xiyou.wangcong@gmail.com
To: pmoore@redhat.com
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <CAGH-Kgv0UpmDdaW=z8pa1VvmrcJeaA57uMneqNEgex6Xa8NSQw@mail.gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Paul Moore <pmoore@redhat.com>
Date: Wed, 30 Nov 2016 15:35:46 -0500

> On Wed, Nov 30, 2016 at 2:58 PM, David Miller <davem@davemloft.net> wrote:
>> From: Paul Moore <pmoore@redhat.com>
>> Date: Tue, 29 Nov 2016 17:11:29 -0500
>>
>>> From: Paul Moore <paul@paul-moore.com>
>>>
>>> Bring back commit bc51dddf98c9 ("netns: avoid disabling irq for netns
>>> id") now that we've fixed some audit multicast issues that caused
>>> problems with original attempt.  Additional information, and history,
>>> can be found in the links below:
>>>
>>>  * https://github.com/linux-audit/audit-kernel/issues/22
>>>  * https://github.com/linux-audit/audit-kernel/issues/23
>>>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> Signed-off-by: Paul Moore <paul@paul-moore.com>
>>
>> This doesn't apply cleanly to the net-next tree, could you please
>> respin?
> 
> As I mentioned in a reply to the patch posting, because this relies on
> a number of patches in the audit tree I've gone ahead and merged this
> patch into the audit#next branch.  Unless you have any objections,
> I'll send this to Linus with the rest of the v4.10 audit patches.

That's fine with me.
