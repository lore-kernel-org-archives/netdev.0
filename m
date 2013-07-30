From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] sky2: detect and prevent kernel panic from a possible
 faulty hardware
Date: Tue, 30 Jul 2013 16:32:17 -0700
Message-ID: <20130730163217.130cbe08@nehalam.linuxnetplumber.net>
References: <1374957354-10142-1-git-send-email-sam8641@gmail.com>
	<20130730.161906.1898764862564749288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sam8641@gmail.com, mlindner@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730.161906.1898764862564749288.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Jul 2013 16:19:06 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Samuel Williams <sam8641@gmail.com>
> Date: Sat, 27 Jul 2013 15:35:54 -0500
> 
> > A possible faulty hardware might interrupt with a status of 0xffffffff which
> > may kernel panic if sky2 driver tries to handle it. Detecting this problem
> > may avoid kernel panic.
> > 
> > Signed-off-by: Samuel Williams <sam8641@gmail.com>
> 
> Sure, but then the device is basically just going to stop.
> 
> I think this change needs to be more comprehensive, for example it
> needs to fully reset the device and try to get it operational again.

Not only that it is going to assert IRQ until the device is hard
reset. Plus it is not clear that cleaning up after sick hardware
is possible at all.
