From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Fri, 8 Sep 2017 10:04:09 -0700
Message-ID: <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
 <20170822.213030.1848111782253505433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <vallish@amazon.com>, <shuah@kernel.org>,
        <richardcochran@gmail.com>, <xiyou.wangcong@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <eduval@amazon.com>, <anchalag@amazon.com>,
        David Woodhouse <dwmw@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170822.213030.1848111782253505433.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Tue, Aug 22, 2017 at 09:30:30PM -0700, David Miller wrote:
> From: Vallish Vaidyeshwara <vallish@amazon.com>
> Date: Wed, 23 Aug 2017 00:10:25 +0000
> 
> > I am submitting 2 patch series to enable hires timer to timeout
> > datagram sockets (AF_UNIX & AF_INET domain) and test code to test
> > timeout accuracy on these sockets.
> 
> This is not reasonable.
> 
> If you want high resolution events with real guarantees, please use
> the kernel interfaces which provide this as explained to you as
> feedback by other reviewers.

I understand the kernel provides other interfaces.

> 
> I'm not applying this, sorry.

However, this is a clear, the system call, from the net subsystem,  has changed in behavior across kernel versions. From application / userspace perspective, changing the system call without clear documentation or deprecation path, to me, looks like breaking userspace, isn't it?

If the correct recommendation is to use different system calls this should have been mentioned in system call documentation before changing its behavior, not expect the user to figure out after kernel release/upgrade, right?


-- 
All the best,
Eduardo Valentin
