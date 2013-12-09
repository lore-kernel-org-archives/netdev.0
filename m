From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] net: unix: allow set_peek_off to fail
Date: Mon, 9 Dec 2013 11:32:46 +0400
Message-ID: <52A5721E.6020709@parallels.com>
References: <1386455187-28597-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <edumazet@google.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386455187-28597-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/08/2013 02:26 AM, Sasha Levin wrote:
> unix_dgram_recvmsg() will hold the readlock of the socket until recv
> is complete.
> 
> In the same time, we may try to setsockopt(SO_PEEK_OFF) which will hang until
> unix_dgram_recvmsg() will complete (which can take a while) without allowing
> us to break out of it, triggering a hung task spew.
> 
> Instead, allow set_peek_off to fail, this way userspace will not hang.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
