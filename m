From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pre-clear the returned sockaddr_storage variable
Date: Tue, 09 Apr 2013 15:05:43 -0400 (EDT)
Message-ID: <20130409.150543.466468818028967750.davem@davemloft.net>
References: <20130409175024.GA19308@www.outflux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	minipli@googlemail.com, spender@grsecurity.net
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130409175024.GA19308@www.outflux.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 9 Apr 2013 10:50:24 -0700

> To avoid future stack content leaks in the various protocols, pre-clear
> the returned memory.
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Suggested-by: Brad Spengler <spender@grsecurity.net>

No thanks, clearing 2 full cache lines unnecessarily on every socket
call has real cost.
