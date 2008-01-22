From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process's security context.
Date: Tue, 22 Jan 2008 08:49:47 -0800 (PST)
Message-ID: <634344.24836.qm@web36604.mail.mud.yahoo.com>
References: <200801230016.EGG34399.QFtVHFSJFMOOLO@I-love.SAKURA.ne.jp>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-security-module@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200801230016.EGG34399.QFtVHFSJFMOOLO@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> ...
> 
> Currently, there is no way to directly map security context from incoming
> packet to user process. This is because the creator or owner of a socket is
> not always the receiver of an incoming packet. The userland process who
> receives the incoming packet is not known until a process calls
> sys_recvmsg().
> So, I want to add a LSM hook to give a security module a chance to control
> after the recipient of the incoming packet is known.

Do you have a real situation where two user processes with different
security contexts share a socket? How do you get into that situation,
and is it appropriate to have that situation in your security scheme?
Can this occur without using privilege?


Casey Schaufler
casey@schaufler-ca.com
