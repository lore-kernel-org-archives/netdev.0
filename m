From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v6 0/3] sctp: check the rto_min and rto_max
Date: Tue, 10 Dec 2013 09:38:56 -0500
Message-ID: <52A72780.4020405@gmail.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com> <52A70E38.9020906@redhat.com> <52A72660.9050403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Wang Weidong <weidong1991.wang@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:38978 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900Ab3LJOjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 09:39:00 -0500
In-Reply-To: <52A72660.9050403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2013 09:34 AM, Wang Weidong wrote:
> From: Wang Weidong <wangweidong1@huawei.com>
> 
> On 2013/12/10 20:51, Daniel Borkmann wrote:
>> On 12/10/2013 03:46 AM, Wang Weidong wrote:
>>> v5 -> v6
>>>    -patch1: do rto_min/max socket option handling in its own patch, and
>>>     fix the check of rto_min/max.
>>>    -patch2: do rto_min/max sysctl handling in its own patch.
>>>    -patch3: add Suggested-by Daniel.
>>
>> Fyi, for future submission, please keep the full changelog.
>>
> 
> Yeah, Thanks! I will do this in future submission.
> 
>> I would have much rather liked seeing you with finishing the last
>> 2 patches first, and then approach the newly introduced 1st one
>> in this series for now. You still haven't fully fixed whitespace
>> issues in your second patch in the function itself which I hoped
>> you would address, but fair enough ...
>>
> 
> As Vlad's suggestion, I split it to 2 patches. Should I combine these
> 2 patch to one?

No, they deserve a separate patch.  What Daniel meant was that you
should have addressed the sysctl control issues first.  It doesn't
really matter all that much here.  In fact the last whitespace patch
is the one that doesn't really fit in this series as it fixes something
quite unrelated to the reset of the series, but we are talking semantics.

I am fine with the series as long as you address the spacing issue
in the new proc handler functions.

> 
> The second patch, do you mean that?
> I should do it from
> 
> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
> +                void __user *buffer, size_t *lenp,
> +                loff_t *ppos);
> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
> +                void __user *buffer, size_t *lenp,
> +                loff_t *ppos);
> 
> to
> 
> +static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
> +                 void __user *buffer, size_t *lenp,
> +                 loff_t *ppos);
> +static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
> +                 void __user *buffer, size_t *lenp,
> +                 loff_t *ppos);
> 
> Just line up to first line? And I should change the third patch as well.

No, the prototypes are fine.  I sent a separate comment pointing out
the spacing issue.

-vlad

> 
> Regards.
> Wang
> 
>>> Wang Weidong (3):
>>>    sctp: check the rto_min and rto_max in setsockopt
>>>    sctp: add check rto_min and rto_max in sysctl
>>>    sctp: fix up a spacing
>>>
>>>   net/sctp/socket.c | 32 +++++++++++++++--------
>>>   net/sctp/sysctl.c | 76
>>> ++++++++++++++++++++++++++++++++++++++++++++++++-------
>>>   2 files changed, 89 insertions(+), 19 deletions(-)
>>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
