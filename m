From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 12:39:45 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119123945.A32623@infradead.org>
References: <20040119123343.GA16292@colin2.muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jt@hpl.hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@colin2.muc.de>
Content-Disposition: inline
In-Reply-To: <20040119123343.GA16292@colin2.muc.de>; from ak@colin2.muc.de on Mon, Jan 19, 2004 at 01:33:43PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 19, 2004 at 01:33:43PM +0100, Andi Kleen wrote:
> It reuses the existing ioctl description table, but renames it to 
> export it (standard_ioctls wasn't a good name for a global variable) 

What about register_ioctl32_conversion() from the wireless code to avoid
exposing it?
