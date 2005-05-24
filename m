From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/6] bnx2: Fix excessive stack usage
Date: Tue, 24 May 2005 01:43:18 -0400
Message-ID: <4292BEF6.2080804@pobox.com>
References: <1116892439.4908.1.camel@rh4> <1116894307.4908.28.camel@rh4> <429286A3.1060606@pobox.com> <1116908956.5984.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1116908956.5984.4.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> On Mon, 2005-05-23 at 21:42 -0400, Jeff Garzik wrote:
> 
>>memleak -- you need to free good_mbuf.
>>
> 
> 
> Oops, here is the revised patch with kfree(). Thanks.
> 
> Fix excessive stack usage in bnx2_alloc_bad_rbuf() by replacing local
> variable array with kmalloc array. Also changed function to return error
> code, and changed some of the callers to check for the return code.
> 
> Spotted by Jeff Garzik.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK
