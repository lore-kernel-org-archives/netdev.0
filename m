From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: unix: allow set_peek_off to fail
Date: Tue, 10 Dec 2013 21:45:46 -0500 (EST)
Message-ID: <20131210.214546.2076606671956419677.davem@davemloft.net>
References: <1386455187-28597-1-git-send-email-sasha.levin@oracle.com>
	<52A5721E.6020709@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sasha.levin@oracle.com, edumazet@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xemul@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52A5721E.6020709@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 9 Dec 2013 11:32:46 +0400

> On 12/08/2013 02:26 AM, Sasha Levin wrote:
>> unix_dgram_recvmsg() will hold the readlock of the socket until recv
>> is complete.
>> 
>> In the same time, we may try to setsockopt(SO_PEEK_OFF) which will hang until
>> unix_dgram_recvmsg() will complete (which can take a while) without allowing
>> us to break out of it, triggering a hung task spew.
>> 
>> Instead, allow set_peek_off to fail, this way userspace will not hang.
>> 
>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>

Applied and queued up for -stable, thanks.
