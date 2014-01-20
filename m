From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/2] sctp: some small clean ups
Date: Mon, 20 Jan 2014 12:37:06 +0100
Message-ID: <52DD0A62.9050807@redhat.com>
References: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49984 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbaATLhd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 06:37:33 -0500
In-Reply-To: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2014 12:27 PM, Wang Weidong wrote:
> We have the macros in sctp.h, so use them for coding accordance
> in sctp.

Thanks for doing this Wang.

I am actually wondering why we have these macro locking wrappers
and not use these functions directly? Hm, any reasons? Maybe we
should rather go in the other direction with this?

> Wang Weidong (2):
>    sctp: use sctp_local_bh_{disable|enable} instead
>      local_bh_{disable|enable}
>    sctp: use sctp_read_[un]lock instead of read_[un]lock
>
>   net/sctp/endpointola.c   |  4 ++--
>   net/sctp/input.c         | 10 +++++-----
>   net/sctp/proc.c          | 12 ++++++------
>   net/sctp/sm_make_chunk.c |  8 ++++----
>   net/sctp/socket.c        |  8 ++++----
>   5 files changed, 21 insertions(+), 21 deletions(-)
>
