From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC][PATCH] net drivers and cache alignment
Date: Sat, 07 Dec 2002 18:42:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF28781.3070405@pobox.com>
References: <3DF2781D.3030209@pobox.com> <20021207.144004.45605764.davem@redhat.com> <3DF27EE7.4010508@pobox.com> <3DF2844C.F9216283@digeo.com> <20021207233745.GE3183@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@redhat.com>,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "J.A. Magallon" <jamagallon@able.es>
In-Reply-To: <20021207233745.GE3183@werewolf.able.es>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

J.A. Magallon wrote:
> On 2002.12.08 Andrew Morton wrote:
> 
>>Jeff Garzik wrote:
>>
>>>David S. Miller wrote:
>>>
>>>>Can't the cacheline_aligned attribute be applied to individual
>>>>struct members?  I remember doing this for thread_struct on
>>>>sparc ages ago.
>>>
>>>Looks like it from the 2.4 processor.h code.
>>>
>>>Attached is cut #2.  Thanks for all the near-instant feedback so far :)
>>>  Andrew, does the attached still need padding on SMP?
>>
> 
> What do you all think about this:
> 
> #include <stdio.h>
> 
> #define CACHE_LINE_SIZE 128
> #define ____cacheline_aligned __attribute__((__aligned__(CACHE_LINE_SIZE)))
> 
> #define __cacheline_start   struct { } ____cacheline_aligned;


if you can mark struct members with attributes, as it appears you can, 
there's no need to define a struct.

	Jeff
