From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] [NET] dont insert socket dentries into
 dentry_hashtable.
Date: Tue, 28 Nov 2006 16:13:54 -0800
Message-ID: <20061128161354.d5c11ba5.akpm@osdl.org>
References: <20061025.230615.92585270.davem@davemloft.net>
	<200610311948.48970.dada1@cosmosbay.com>
	<200611221900.36216.dada1@cosmosbay.com>
	<20061128.153531.34751359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757964AbWK2AOe@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061128.153531.34751359.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Nov 2006 15:35:31 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> 
> Andrew, I'm fine with these three patches, specifically:
> 
> [PATCH] dont insert pipe dentries into dentry_hashtable.
> [PATCH] [DCACHE] : avoid RCU for never hashed dentries
> [PATCH] [NET] dont insert socket dentries into dentry_hashtable.
> 
> Could you toss them into -mm if you haven't already?

They were in rc6-mm2.

>  This
> makes better sense then me putting it into net-2.6.20 since
> it touches FS stuff.
> 

No probs, they're all lined up and ready to go, thanks.
