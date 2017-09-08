From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Fri, 08 Sep 2017 10:16:57 -0700 (PDT)
Message-ID: <20170908.101657.2131282706895004921.davem@davemloft.net>
References: <1503447027-44399-1-git-send-email-vallish@amazon.com>
        <20170822.213030.1848111782253505433.davem@davemloft.net>
        <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vallish@amazon.com, shuah@kernel.org, richardcochran@gmail.com,
        xiyou.wangcong@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, anchalag@amazon.com, dwmw@amazon.com
To: eduval@amazon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eduardo Valentin <eduval@amazon.com>
Date: Fri, 8 Sep 2017 10:04:09 -0700

> However, this is a clear, the system call, from the net subsystem,
> has changed in behavior across kernel versions. From application /
> userspace perspective, changing the system call without clear
> documentation or deprecation path, to me, looks like breaking
> userspace, isn't it?

Where is the chapter and verse of the system call documentation that
guaranteed this level of timer granularity for you?

Or were you simply relying upon implementation dependent behavior?
I can't see anything which ever guarateed the granularity of timers
to the extent upon which you were relying.

And most importantly, letting the kernel have flexibility in this area
is absolutely essential for various forms of optimizations and power
savings.
