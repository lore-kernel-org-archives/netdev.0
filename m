From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 04:27:26 -0700 (PDT)
Message-ID: <20100531.042726.212700126.davem@davemloft.net>
References: <alpine.OSX.2.00.1005290255580.691@localhost>
	<20100531.001947.193703044.davem@davemloft.net>
	<alpine.LNX.2.00.1005311905520.469@nippy.intranet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1005311905520.469@nippy.intranet>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: fthain@telegraphics.com.au
Date: Mon, 31 May 2010 19:21:26 +1000 (EST)

> Your suggestion to use pr_debug is invoking compile time infrastructure 
> (the DEBUG macro), so it is not in the spirit of this commit, and it is 
> not relevant to any criticism from you or Joe of the earlier submissions.
> 
> Please apply the patch.

I won't do that, because your change elides the pr_fmt prefix Joe
Perches added to the driver for the purposes of making sure such a
prefix would be added to all log messages output by the driver.

The whole idea is that everything the driver puts into the kernel
log has the driver module name at the beginning.  That's what the
pr_fmt define at the top of the driver does.

It's so you can tell which driver the message came from.

You're undoing that, which is a bug.  It's a step backwards, it's
wrong.

And to top it off we've had to explain this stuff to you multiple
times.

So, as long as the patch is incorrect I absolutely will not apply it.
