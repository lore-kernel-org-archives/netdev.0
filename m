From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 06/13] ppc 8260 fcc ethernet driver cannot read LXT971
 PHY id
Date: Wed, 16 Mar 2005 13:13:06 -0500
Message-ID: <42387732.5030500@pobox.com>
References: <200503152222.j2FMMccq016808@shell0.pdx.osdl.net> <20050315232651.3fd10b13.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, oray@lucent.com
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050315232651.3fd10b13.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> akpm@osdl.org wrote:
> 
>>From: "Balasaygun, Oray (Oray)" <oray@lucent.com>
>>
>> - fix for Bug 4310
>>
>> - The fcc_enet.c, as distributed in 2.6.10, does not compile.  Evidently
>>   the 2.6 kernel no longer supports the schedule_task() and "struct
>>   tq_struct" to go with it.  Lines 73 through and including 96 of the
>>   diffout file show the changes I made to port schedule_task() into
>>   tasklet_schedule().  I should have reported this as a bug too but I
>>   forgot about it.
>>
>> - customize fcc_enet.c to work with my custom board.  These changes are
>>   conditional on CONFIG_EON8260 being defined.
> 
> 
> Jeff, don't apply this please - we're getting a bunch of patches for this
> driver coming from another direction (mvista, freescale.com).  Will take
> some time to sort through.

All they have to do is send them to the net driver maintainer -- me -- 
and they get sorted through.

	Jeff
