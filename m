From: Andrew Morton <akpm@osdl.org>
Subject: Re: slab corruption in skb allocs
Date: Mon, 21 Mar 2005 14:36:48 -0800
Message-ID: <20050321143648.4608a912.akpm@osdl.org>
References: <42283093.7040405@inode.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Jeff Garzik
 <jgarzik@pobox.com>
To: Richard Fuchs <richard.fuchs@inode.info>
In-Reply-To: <42283093.7040405@inode.info>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Fuchs <richard.fuchs@inode.info> wrote:
>
> he memory allocation debugger gives me the following messages under a
> vanilla 2.6.10 and 2.6.11 kernel when doing
> 
> 1) hdparm -d0 on my hard disk
> 2) tar c / > /dev/null
> 3) sending lots of network traffic to the machine (e.g. close to 100
> mbit/s udp packets)
> 

We ended up deciding that this was a bug in the e100 NAPI implementation.

I have a not-very-official patch in -mm, at
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.12-rc1/2.6.12-rc1-mm1/broken-out/e100-napi-state-machine-fix.patch.
Would you be able to test that?

AFAIK there has been no official fix for this yet.
