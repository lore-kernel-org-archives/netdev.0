From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH] Allow passing tid or pid in SCM_CREDENTIALS
 without CAP_SYS_ADMIN
Date: Tue, 29 Aug 2017 16:02:32 -0700 (PDT)
Message-ID: <20170829.160232.1901318933754673000.davem@davemloft.net>
References: <1503965540-30393-1-git-send-email-prakash.sangappa@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        ebiederm@xmission.com, drepper@redhat.com
To: prakash.sangappa@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503965540-30393-1-git-send-email-prakash.sangappa@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Prakash Sangappa <prakash.sangappa@oracle.com>
Date: Mon, 28 Aug 2017 17:12:20 -0700

> Currently passing tid(gettid(2)) of a thread in struct ucred in
> SCM_CREDENTIALS message requires CAP_SYS_ADMIN capability otherwise
> it fails with EPERM error. Some applications deal with thread id
> of a thread(tid) and so it would help to allow tid in SCM_CREDENTIALS
> message. Basically, either tgid(pid of the process) or the tid of
> the thread should be allowed without the need for CAP_SYS_ADMIN capability.
> 
> SCM_CREDENTIALS will be used to determine the global id of a process or
> a thread running inside a pid namespace.
> 
> This patch adds necessary check to accept tid in SCM_CREDENTIALS
> struct ucred.
> 
> Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>

I'm pretty sure that by the descriptions in previous changes to this
function, what you are proposing is basically a minor form of PID
spoofing which we only want someone with CAP_SYS_ADMIN over the
PID namespace to be able to do.

Sorry, I'm not applying this.
