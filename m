From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: The ultimate TOE design
Date: Wed, 15 Sep 2004 16:25:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4148A51F.7030909@pobox.com>
References: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, leonid.grossman@s2io.com,
        Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF8783A4F6.D566336C-ON88256F10.006E51CE-88256F10.006EDA93@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> I've never understood why people are so interested in off-loading
> networking. Isn't that just a multi-processor system where you can't
> use any of the network processor cycles for anything else? And, of
> course, to be cheap, the network processor will be slower, and much
> harder to debug and update software.

Well I do agree there is a strong don't-bother-with-TOE argument: 
Moore's law, the CPUs (manufactured in vast quantities) will usually


However, there are companies are Just Gotta Do TOE...  and I am not 
inclined to assist in any effort that compromises Linux's RFC compliancy 
or security.  Current TOE efforts seem to be of the "shove your data 
through this black box" variety, which is rather disheartening.

Even non-TOE NICs these days have ever-more-complex firmwares.  tg3 is a 
MIPS-based engine for example.


> If the PCI bus is too slow, or MTU's too small, wouldn't
> it be better to fix those directly and use a fast host processor that can
> also do other things when not needed for networking? And why have
> memory on a NIC that can't be used by other things?

PCI bus tends to be slower than DRAM<->CPU speed, and MTUs across the 
Internet will be small as long as ethernet enjoys continued success.

	Jeff
