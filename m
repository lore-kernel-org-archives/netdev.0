From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Unable to handle kernel paging request at virtual address
 04000460
Date: Thu, 2 Jun 2005 10:44:23 -0700
Message-ID: <20050602104423.2c3825e5@dxpl.pdx.osdl.net>
References: <438662DA48DCAA41B1DF648BD4BD76C0E461B8@CHN-SNR-MBX01.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>, <linux@der-keiler.de>
Return-path: <linux-net-owner@vger.kernel.org>
To: <raghunathan.venkatesan@wipro.com>
In-Reply-To: <438662DA48DCAA41B1DF648BD4BD76C0E461B8@CHN-SNR-MBX01.wipro.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Jun 2005 09:20:21 +0530
<raghunathan.venkatesan@wipro.com> wrote:

> Hi David,
> I understand that the linux community may not be able to debug it for
> me. All I require is if people have seen similar problems (the problems
> we face are w.r.t to kfree_skb and skb_drop_fraglist crashing due to
> some reason, which could be a Memory Management issue or some thing we
> are not aware of), then let us know the patches, so that we can try them
> out here.

Turn on Debug memory allocations, spinlock debugging, sleep-inside-spinlock
checking, and preempt, it will help your debugging.  If you are not building
your own kernel from source learn how.

You are probably freeing memory twice, or not doing ref counting properly
or other locking issues.  Since it is your code, good luck debugging it,
if you want the community help it needs to be open source code that
is available for download or be in the kernel.org kernel.
