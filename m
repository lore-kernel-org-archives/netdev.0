From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] tulip VLAN support
Date: Wed, 05 Jan 2005 14:17:57 -0800
Message-ID: <41DC6795.6060000@candelatech.com>
References: <20050105193425.GY18847@sventech.com> <41DC6669.9090407@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Erdfelt <johannes@erdfelt.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41DC6669.9090407@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Johannes Erdfelt wrote:
> 
>> @@ -259,7 +259,7 @@
>>  #define RX_RING_SIZE    128  #define MEDIA_MASK     31
>>  
>> -#define PKT_BUF_SZ        1536    /* Size of each temporary Rx 
>> buffer. */
>> +#define PKT_BUF_SZ        1540    /* Size of each temporary Rx 
>> buffer. */
> 
> 
> 
> This is the reason why the tulip "vlan" patch is continually rejected. 
> You shouldn't need to increase this constant, but rather follow the 
> other "large MTU" driver conversions.

Has anyone tried just leaving this line as it was (but adding the rest
of the patch)?  I believe the 1536 already has plenty of space and
can hold the extra 4 bytes w/out problem.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
