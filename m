From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: IP More Fragements bit problem.
Date: Fri, 11 Feb 2005 10:44:47 -0800
Message-ID: <420CFD1F.2060701@us.ibm.com>
References: <200502111708.16024.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Trond Myklebust <trond.myklebust@fys.uio.no>,
        Tony Reix <Tony.Reix@Bull.Net>
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200502111708.16024.vincent.roqueta@ext.bull.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vincent Roqueta wrote:

> On kernel 2.6.10rc2 and laters (last tested is 2.6.11-rc3) we have: 
> 
> A + MF
> B + MF
> C + MF
> D + MF
> 
> That cause AIX waiting for the last packet with out sending ack
> So Linux suppose  AIX didn't receive all, and re send all packets.
> So AIX is receiving that: 
> A + MF
> B + MF
> C + MF
> D + MF
> *DELAY *

Silly question, but are you absolutely sure that the original wasn't
actually ABCDE?

thanks,
Nivedita
