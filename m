From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 14:10:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119141041.2cccbc3d.ak@suse.de>
References: <20040119123343.GA16292@colin2.muc.de>
	<20040119123945.A32623@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@colin2.muc.de, netdev@oss.sgi.com, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040119123945.A32623@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 12:39:45 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Jan 19, 2004 at 01:33:43PM +0100, Andi Kleen wrote:
> > It reuses the existing ioctl description table, but renames it to 
> > export it (standard_ioctls wasn't a good name for a global variable) 
> 
> What about register_ioctl32_conversion() from the wireless code to avoid
> exposing it?

At least for net/* stuff it seems to be standard to do it in the central file.
All other networking ioctls are implemented this way too.

-Andi
