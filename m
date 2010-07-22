From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Wed, 21 Jul 2010 22:06:11 -0700 (PDT)
Message-ID: <20100721.220611.267376790.davem@davemloft.net>
References: <201007220441.o6M4fcmC093106@www262.sakura.ne.jp>
	<20100721.214517.236270570.davem@davemloft.net>
	<201007220502.o6M52GJU098071@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007220502.o6M52GJU098071@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 22 Jul 2010 14:02:16 +0900

> Then, why does below proposal lose information?

Peek changes state, now it's possible that two processes end up
receiving the packet.

Please consider deeply how your desired semantics are unobtainable
without breaking thigngs fundamentally.
