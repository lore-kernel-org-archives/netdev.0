From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ar9170: fix for driver-core ABI change
Date: Tue, 09 Mar 2010 19:00:02 +0100
Message-ID: <4B968CA2.4040000@s5r6.in-berlin.de>
References: <20100309104221.aedc5e7e.sfr@canb.auug.org.au> <20100309125245.c25e5ca4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-next@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100309125245.c25e5ca4.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> Greg tells me that the semaphore to mutex change didn't go into Linus'
> tree.  However, this patch can still be applied as the device_lock/unlock
> primitives did go in.  I guess that the include of mutex.h is not needed.

An #include <linux/device.h> seems to be in order though.  It is pulled
in via linux/usb.h and this is surely not bound to change anytime soon,
but still.
-- 
Stefan Richter
-=====-==-=- --== -=--=
http://arcgraph.de/sr/
