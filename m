From: Rick Jones <rick.jones2@hp.com>
Subject: Re: is UDP_CORK "real"
Date: Thu, 21 Apr 2005 16:53:44 -0700
Message-ID: <42683D08.7030201@hp.com>
References: <426833F0.9010803@hp.com> <20050421162505.3db8ed7c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050421162505.3db8ed7c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 21 Apr 2005 16:14:56 -0700
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> 
>>Is UDP_CORK going to be an ongoing feature?
> 
> 
> Yes, it's there and it's real.
> 
> If netperf is passing a TCP socket option number in for
> a setsockopt() on a UDP socket, how in the world is that
> the kernel's problem?


I didn't really mean to say that it was a kernel problem per se. I was trying to 
understand the space, make sure that it was deliberate that there were actual 
overlaps between the TCP_mumble and UDP_mumble options and such.  The release 
bits for netperf 2.4.0 will have checks to make sure it does not try to set 
"TCP_NODLEAY" on a UDP socket.  Call it a 13 year lingering misfeature in 
netperf if you like :)

rick jones
