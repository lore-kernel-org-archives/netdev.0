From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] irda: replace current->state by
 set_current_state()
Date: Mon, 23 Feb 2015 17:21:25 -0500 (EST)
Message-ID: <20150223.172125.1327512956032057269.davem@davemloft.net>
References: <1424713105-12845-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
	samuel@sortiz.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424713105-12845-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 23 Feb 2015 18:38:24 +0100

> Use helper functions to access current->state.
> Direct assignments are prone to races and therefore buggy.
> 
> current->state = TASK_RUNNING can be replaced by __set_current_state()
> 
> Thanks to Peter Zijlstra for the exact definition of the problem.
> 
> Suggested-By: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
