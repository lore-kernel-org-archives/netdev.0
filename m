From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7 linux-next] mISDN: replace current->state by
 set_current_state()
Date: Sun, 22 Feb 2015 15:24:45 -0500 (EST)
Message-ID: <20150222.152445.730394302519791309.davem@davemloft.net>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
	<1424455977-21903-2-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	peterz@infradead.org, gregkh@linuxfoundation.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-2-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 20 Feb 2015 19:12:52 +0100

> Use helper function to access current->state.
> Direct assignments are prone to races and therefore buggy.
> 
> Thanks to Peter Zijlstra for the exact definition of the problem.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
