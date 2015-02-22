From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 linux-next] wan: cosa: replace current->state by
 set_current_state()
Date: Sun, 22 Feb 2015 15:25:05 -0500 (EST)
Message-ID: <20150222.152505.101749483886283097.davem@davemloft.net>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
	<1424455977-21903-6-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	peterz@infradead.org, gregkh@linuxfoundation.org, kas@fi.muni.cz,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-6-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 20 Feb 2015 19:12:56 +0100

> Use helper functions to access current->state.
> Direct assignments are prone to races and therefore buggy.
> 
> current->state = TASK_RUNNING is replaced by __set_current_state()
> 
> Thanks to Peter Zijlstra for the exact definition of the problem.
> 
> Suggested-By: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
