From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 02 Aug 2011 05:01:15 -0700 (PDT)
Message-ID: <20110802.050115.1714327089688495866.davem@davemloft.net>
References: <20110802.041857.1325765319466840715.davem@davemloft.net>
	<20110802.042641.2122529993066553943.davem@davemloft.net>
	<201108022052.FBE56208.FLQHFtMOVOSOJF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108022052.FBE56208.FLQHFtMOVOSOJF@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Tue, 2 Aug 2011 20:52:05 +0900

> David Miller wrote:
>> Actually, I change my mind. :-)
>> 
>> I think sendmmsg() needs to unconditionally not report an error if any
>> datagrams were sent successfully.
> 
> What about adding

I much prefer to make the error handling more correct, rather than
making sendmmsg() have fundamentally different semantics depending
upon the underlying LSM.
