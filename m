From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 12/13] pcnet32 79C975 fiber fix
Date: Tue, 22 Mar 2005 14:14:09 -0500
Message-ID: <42406E81.3090202@pobox.com>
References: <200503152222.j2FMMiLB016826@shell0.pdx.osdl.net>	<20050316005630.GA9421@us.ibm.com> <20050315170322.3398bd60.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Don Fry <brazilnut@us.ibm.com>, davem@davemloft.net, netdev@oss.sgi.com,
        steven.hardy@astrium.eads.net
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20050315170322.3398bd60.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Don Fry <brazilnut@us.ibm.com> wrote:
> 
>>I had not seen this problem until now.  The patch looks ok and
>> probably should have been written that way initially.  I have been
>> able to do a quick touch test with a 970A, 971, 972, 973, 975, 976, and
>> 978 (some on ia32 and others on ppc64) without any adverse effects.
>> The 975 I have is copper not fiber.
> 
> 
> Great, thanks.
> 
> 
>> Since only bit 12 is needed to enable LED writes, the code could
>> really be "a->write_bcr(ioaddr, 2, a->read_bcr(ioaddr, 2) | 0x1000);"
>> During pcnet32_open the ASEL bit is changed anyway.
> 
> 
> OK, could you please prepare a final patch sometime and get it into Jeff? 
> cc me as well please so I can update the patch I have.

Yes, please do Don, if you have the time.

	Jeff
