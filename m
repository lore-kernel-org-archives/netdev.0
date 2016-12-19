From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [v3] net: ethernet: cavium: octeon: octeon_mgmt: Handle return
 NULL error from devm_ioremap
Date: Mon, 19 Dec 2016 13:37:35 -0800
Message-ID: <49c07a34-ad57-518f-66f5-2a4f70f6a095@gmail.com>
References: <1481742210-5609-1-git-send-email-arvind.yadav.cs@gmail.com>
 <20161219.110420.1570801461162159172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peter.chen@nxp.com, fw@strlen.de, david.daney@cavium.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161219.110420.1570801461162159172.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/19/2016 08:04 AM, David Miller wrote:
> From: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Date: Thu, 15 Dec 2016 00:33:30 +0530
>
>> Here, If devm_ioremap will fail. It will return NULL.
>> Kernel can run into a NULL-pointer dereference.
>> This error check will avoid NULL pointer dereference.
>>
>> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
>
> Since ioremap() is in fact designed to possibly fail, we do
> need to always check it's return value.  So this change is
> correct and I have applied it to the 'net' tree.

Yes, I think that is fine, although I have not tested the patch.

In general I like to know if a patch fixes a problem that has occurred 
on a platform used by the patch author, or if the author just noticed an 
issue through code inspection or automated tool for a platform that they 
cannot test on.

This patch appears to fall into the second category, but attempts to 
determine this for sure were for the most part unsuccessful.

With respect to ioremap(), in general I agree that it is designed to 
possibly fail.  For mips64 however, I think the implementation can never 
fail.  Certainly testing for failure fits better with what we expect to 
see in Linux kernel code.


>
> Thanks.
>
