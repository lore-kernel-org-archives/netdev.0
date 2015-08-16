From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] rhashtable-test: extend to test concurrency
Date: Sun, 16 Aug 2015 20:12:35 +0200
Message-ID: <20150816181234.GC31357@breakpoint.cc>
References: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439591835-30357-1-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Sutter <phil@nwl.cc> wrote:
> After having tested insertion, lookup, table walk and removal, spawn a
> number of threads running operations on the same rhashtable. Each of
> them will:

[..]

> +	if (down_interruptible(&startup_sem))
> +		pr_err("  thread[%d]: down_interruptible failed\n", tdata->id);

Why _interruptible?

Seems this should use down() instead.
