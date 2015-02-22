From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7 linux-next] hso: replace current->state by
 __set_current_state()
Date: Sun, 22 Feb 2015 15:25:00 -0500 (EST)
Message-ID: <20150222.152500.1079314983789857968.davem@davemloft.net>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
	<1424455977-21903-5-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mingo@redhat.com,
	peterz@infradead.org, gregkh@linuxfoundation.org,
	j.dumon@option.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-5-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 20 Feb 2015 19:12:55 +0100

> Use helper functions to access current->state.
> Direct assignments are prone to races and therefore buggy.
> 
> Thanks to Peter Zijlstra for the exact definition of the problem.
> 
> Suggested-By: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
