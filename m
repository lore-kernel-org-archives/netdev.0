From: Ben Greear <greearb@candelatech.com>
Subject: Re: Ethernet bridge performance
Date: Thu, 07 Aug 2003 12:50:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F32AD9D.4010504@candelatech.com>
References: <3F3217E7.2080903@allot.com>	<3F3284EA.5050406@candelatech.com> <20030807123547.1dcf2353.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: felix@allot.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030807123547.1dcf2353.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Thu, 07 Aug 2003 09:57:14 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Btw, I've considered saving, say, 10k skbs on a list in my module,
>>allocated by GFP_KERNEL at module load time, and using them when
>>GFP_ATOMIC skb_alloc fails in the IRQ handling portion of the code....
>>
>>Anyone think that's a good idea? :)
> 
> 
> Not really.
> 
> GFP_ATOMIC should not fail regularly under normal (even heavy load)
> operation.  If it does, it means the amount of reserved pages
> the kernel keeps around is not set correctly for your system.
> 
> In 2.6.x, play with /proc/sys/vm/min_free_kbytes

Anything to set for 2.4?  I've looked for how to tune the 2.4 VM for
some time, but never found anything.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
