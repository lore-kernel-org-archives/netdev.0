From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] s390: qeth tcp segmentation offload
Date: Mon, 28 Mar 2005 23:09:29 -0800
Message-ID: <20050328230929.639e51f3.akpm@osdl.org>
References: <200503290533.j2T5X0ZZ028790@hera.kernel.org>
	<4248FD8D.6030208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4248FD8D.6030208@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> Please help me understand:  why add all this TSO code (zerocopy), if you 
>  are adding memcpy() under the hood?
> 
>  Was this reviewed on netdev?  or by any network developer?
> 
>  Overall this patch adds a whole lot of code that must be VERY intimate 
>  with the net stack, a huge maintenance burden that is likely to be rife 
>  with out-of-date code and bugs over time.
> 

There was some dicussion on linux-net last Thursday.
