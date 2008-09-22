From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Mon, 22 Sep 2008 15:22:36 -0600
Message-ID: <48D80C9C.2070108@nortel.com>
References: <20080919.234824.223177211.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753368AbYIVVW4@vger.kernel.org>
In-Reply-To: <20080919.234824.223177211.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Jens Axboe has written some hacks for the block layer that allow
> queueing softirq work to remote cpus.  In the context of the block
> layer he used this facility to trigger the softirq block I/O
> completion on the same cpu where the I/O was submitted.

<snip>

> I intend to use this
> for receive side flow seperation on non-multiqueue network cards.

I'm not sure this belongs in this particular thread but I was
interested in how you're planning on doing this?  Is there going to be a
way for userspace to specify which traffic flows they'd like to direct
to particular cpus, or will the kernel try to figure it out on the fly?

We have application guys that would like very much to be able to nail 
specific apps to specific cores and have the kernel send all their 
packets to those cores for processing.

Chris
