From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v6 0/3] sctp: check the rto_min and rto_max
Date: Tue, 10 Dec 2013 13:51:04 +0100
Message-ID: <52A70E38.9020906@redhat.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326Ab3LJMvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 07:51:17 -0500
In-Reply-To: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2013 03:46 AM, Wang Weidong wrote:
> v5 -> v6
>    -patch1: do rto_min/max socket option handling in its own patch, and
>     fix the check of rto_min/max.
>    -patch2: do rto_min/max sysctl handling in its own patch.
>    -patch3: add Suggested-by Daniel.

Fyi, for future submission, please keep the full changelog.

I would have much rather liked seeing you with finishing the last
2 patches first, and then approach the newly introduced 1st one
in this series for now. You still haven't fully fixed whitespace
issues in your second patch in the function itself which I hoped
you would address, but fair enough ...

> Wang Weidong (3):
>    sctp: check the rto_min and rto_max in setsockopt
>    sctp: add check rto_min and rto_max in sysctl
>    sctp: fix up a spacing
>
>   net/sctp/socket.c | 32 +++++++++++++++--------
>   net/sctp/sysctl.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>   2 files changed, 89 insertions(+), 19 deletions(-)
>
