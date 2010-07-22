From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Wed, 21 Jul 2010 21:45:17 -0700 (PDT)
Message-ID: <20100721.214517.236270570.davem@davemloft.net>
References: <201007220338.o6M3citW076383@www262.sakura.ne.jp>
	<20100721.210636.197931242.davem@davemloft.net>
	<201007220441.o6M4fcmC093106@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201007220441.o6M4fcmC093106@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 22 Jul 2010 13:41:38 +0900

> Excuse me, below check is made inside recvmsg() and may return error if
> SELinux's policy has changed after the select() said "ready" and before
> security_socket_recvmsg() is called. No?

It does this before pulling the packet out of the receive queue of the
socket.  It's like signalling a parameter error to the process, no
socket state is changed.
