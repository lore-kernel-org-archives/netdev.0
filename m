From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: active URB submitted multiple times
Date: Fri, 12 Apr 2013 15:18:24 -0400 (EDT)
Message-ID: <20130412.151824.2029469075886743722.davem@davemloft.net>
References: <20130410.232241.1038793023507666278.davem@davemloft.net>
	<alpine.DEB.2.02.1304110956110.4237@fry>
	<alpine.DEB.2.02.1304112156520.4309@fry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sarah.a.sharp@linux.intel.com, dcbw@redhat.com
To: petkan@nucleusys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1304112156520.4309@fry>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>
Date: Thu, 11 Apr 2013 22:00:59 +0300 (EEST)

> From: Petko Manolov <petkan@nucleusys.com>
> 
> (For inclusion in 3.10, diff against latest net-next.)
> 
> Pegasus driver used single callback for sync and async control URBs. 
> Special flags were employed to distinguish between both, but due to flawed 
> logic (as Sarah Sharp spotted) it didn't always work.  As a result of this 
> change [get|set]_registers() are now much simpler.  Async write is also 
> leaner and does not use single, statically allocated memory for 
> usb_ctrlrequest, which is another potential race when asynchronously 
> submitting URBs.
> 
> The socket buffer pool for the receive path is now gone.  It's existence 
> didn't make much difference (performance-wise) and the code is better off 
> without the spinlocks protecting it.
> 
> Largely duplicated code in routines reading and writing MII registers is 
> now packed in __mii_op().
> 
> Adding URL for the public pegasus git repository.
> 
> Signed-off-by: Petko Manolov <petkan@nucleusys.com>

When submitting a new version of a patch, you must list what
changed from the previous version after the "---" delimiter
rather than having people try and guess.

> +T:	git git://petkan@git.code.sf.net/p/pegasus2/git

There is no way that specifying your GIT login in this URL
meant for public use is correct, or is it?
