From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 14:10:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415B24C0.2020208@us.ibm.com>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        herbert@gondor.apana.org.au, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner wrote:

> On Wed, 29 Sep 2004, Andi Kleen wrote:
> 
> 
>>I tried to re-test it but I didn't get very far because the kernel
>>with your patch crashes regularly during netperf. No serial console,
>>but the backtrace is {tcp_ack+877} {tcp_rcv_established+350} ...
>>Before that there are a few "retrans out leaked" messages.
> 
> 
> I just tried to re-create this situation, and I got the same problem.
> Latest bk tree with dave's 5 patches, gcc 3.3.4, uni-processor p4/e1000 to
> a slow-ish p3/sk98lin (dual-cpu but with maxcpus=1).

I just crashed too, no backtrace. netperf tcp stream test,
and was on bk14 + dave's 5 patches, p4/e1000 -> Intel Pentium
M proc (1.7GHz). Going to repeat on slower SMPs with serial
console, get more info..

thanks,
Nivedita
