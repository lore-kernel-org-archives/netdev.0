From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Sun, 8 Feb 2004 12:43:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208124326.2381b974.davem@redhat.com>
References: <20040207144405.GA19416@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040207144405.GA19416@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 7 Feb 2004 15:44:05 +0100
Christoph Hellwig <hch@lst.de> wrote:

> The rpciod shutdown code gives ugly sleep_on without BKL warnings in
> -mm.  And it looks indeed somewhat racy.
> 
> The easy fix would be to simply use a completion as in the patch below,
> but that removes all the signal fuzzing semantics the current code has.
> I don't really understand why we want to cancel the operation by
> signals, but I think it'd be better to leave that to people familar with
> the code anyway..

I think your patch is fine, and there are no signal issues (such code looks
merely to be some abberation rather than anything else).

So I've added it to my tree.
