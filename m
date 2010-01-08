From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] lib/vsprintf.c: Add %pMF to format FDDI bit
 reversed MAC addresses
Date: Thu, 07 Jan 2010 16:58:35 -0800 (PST)
Message-ID: <20100107.165835.10951349.davem@davemloft.net>
References: <1262888625.10429.23.camel@Joe-Laptop.home>
	<e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
	<1262900630.10429.80.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirqus@gmail.com, hartleys@visionengravers.com,
	macro@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754548Ab0AHA62@vger.kernel.org>
In-Reply-To: <1262900630.10429.80.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 07 Jan 2010 13:43:50 -0800

> On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
>> The example below shows an address, and the sequence of bits or symbols 
>> that would be transmitted when the address is used in the Source Address 
>> or Destination Address fields on the MAC header.  The transmission line 
>> shows the address bits in the order transmitted, from left to right.  For 
>> IEEE 802 LANs these correspond to actual bits on the medium.  The FDDI 
>> symbols line shows how the FDDI PHY sends the address bits as encoded 
>> symbols.
>> 
>>         MSB:            35:7B:12:00:00:01
>>         Canonical:      AC-DE-48-00-00-80
>>         Transmission:   00110101 01111011 00010010 00000000 00000000 00000001
>>         FDDI Symbols:   35 7B 12 00 00 01"
>> 
>> Please note that this address has its group bit clear.
>> 
>>  This notation is also defined in the "FDDI MEDIA ACCESS CONTROL-2 
>> (MAC-2)" (X3T9/92-120) document although that book does not have a need 
>> to use the MSB form and it's skipped.
> 
> Adds 6 bytes to object size for x86
> 
> New:
> $ size lib/vsprintf.o
>    text	   data	    bss	    dec	    hex	filename
>    8664	      0	      2	   8666	   21da	lib/vsprintf.o
> $ size lib/vsprintf.o
>    text    data     bss     dec     hex filename
>    8658       0       2    8660    21d4 lib/vsprintf.o
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
