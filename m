From: fthain@telegraphics.com.au
Subject: Re: [PATCH] mac8390: change an error return code and some cleanup,
 take 4
Date: Mon, 31 May 2010 19:21:26 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1005311905520.469@nippy.intranet>
References: <alpine.OSX.2.00.1004171258330.358@localhost> <20100421.163041.158540277.davem@davemloft.net> <alpine.OSX.2.00.1005290255580.691@localhost> <20100531.001947.193703044.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: joe@perches.com, p_gortmaker@yahoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20100531.001947.193703044.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 31 May 2010, David Miller wrote:

> This is getting tiring Finn.

I agree. My patch addresses all of the criticism of the earlier 
submissions.

To make it plain: there are 25 files or so that use ei_debug. Three of 
those that now have the KERN_DEBUG printk's suppresed by the DEBUG macro 
only do so as an apparently unintended side effect of a commit that claims 
to "implement dynmic debug infrastructure". (Go figure.)

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=dd0fab5b940c0b65f26ac5b01485bac1f690ace6

Your suggestion to use pr_debug is invoking compile time infrastructure 
(the DEBUG macro), so it is not in the spirit of this commit, and it is 
not relevant to any criticism from you or Joe of the earlier submissions.

Please apply the patch.

Finn
