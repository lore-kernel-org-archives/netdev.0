From: "David S. Miller" <davem@redhat.com>
Subject: Re: kiocb->private is too large for kiocb's on-stack
Date: Mon, 28 Jun 2004 11:25:10 -0700
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20040628112510.509d08f7.davem@redhat.com>
References: <20040628080801.GO21066@holomorphy.com>
	<20040628011232.43acd3b8.akpm@osdl.org>
	<20040628082016.GP21066@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: William Lee Irwin III <wli@holomorphy.com>
In-Reply-To: <20040628082016.GP21066@holomorphy.com>
List-Id: netdev.vger.kernel.org

On Mon, 28 Jun 2004 01:20:16 -0700
William Lee Irwin III <wli@holomorphy.com> wrote:

> On Mon, Jun 28, 2004 at 01:12:32AM -0700, Andrew Morton wrote:
> > That's so much better than what we had before it ain't funny.
> > Was this runtime tested?
> 
> Yes. Oracle exercises this, and it survives OAST.
> 
> I'll write a dedicated userspace testcase for the aio operations and
> follow up with that.

This all looks fine to me.  Andrew, would you like me to push this
patch along or did you already plan to take care of it.

Nice work William.
