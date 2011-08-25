From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RFC: Remove unnecessary / duplicate OOM printks
Date: Thu, 25 Aug 2011 15:04:56 -0700
Message-ID: <20110825150456.fc8720c4.akpm@linux-foundation.org>
References: <1314305243.4637.10.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314305243.4637.10.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Aug 2011 13:47:23 -0700
Joe Perches <joe@perches.com> wrote:

> There are many thousands of printks for OOM conditions
> in kernel sources.
> 
> These are almost always a duplication of a generic
> OOM message from the mm subsystem.
> 
> The biggest difference between the generic OOM and
> the specific OOM uses is that most of the specific
> messages are emitted at KERN_ERR but the generic
> message is at KERN_WARNING.
> 
> Many KB of code/text could be removed from the kernel.
> 
> Removal can be gradual and done by subsystem.
> 
> Some kmalloc's that are followed on failure by vmalloc
> may need to add GFP_NOWARN.
> 
> Does anyone really believe the per site failure
> messages are useful or really want them to keep them?
> 

Kill 'em.
