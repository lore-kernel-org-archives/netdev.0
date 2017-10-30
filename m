From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: Use common error handling code in ravb_probe()
Date: Tue, 31 Oct 2017 00:19:01 +0300
Message-ID: <587725d6-2eeb-c95c-1cfe-0c6571a74c7c@cogentembedded.com>
References: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
 <b45f9416-5b89-17e3-df0b-905dd01d5342@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eugeniu Rosca <erosca@de.adit-jv.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yuval Shaia <yuval.shaia@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b45f9416-5b89-17e3-df0b-905dd01d5342@cogentembedded.com>
Content-Language: en-MW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2017 11:51 PM, Sergei Shtylyov wrote:

>> From: Markus Elfring <elfring@users.sourceforge.net>
>> Date: Sat, 28 Oct 2017 19:10:08 +0200
>>
>> Add a jump target so that a bit of exception handling can be better reused
>> at the end of this function.
> 
>     Have you actually tried to see if there's any change in the resulting 
> object code? I've looked at ARM gcc 4.8.5's output and it didn't really change 
> -- gcc was able to optimize these repetitive assignments pretty well...
> 
>> This issue was detected by using the Coccinelle software.
>>
>> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
>> ---
>>   drivers/net/ethernet/renesas/ravb_main.c | 32 
>> ++++++++++++++++----------------
>>   1 file changed, 16 insertions(+), 16 deletions(-)
> 
>     Diffstat also speaks about the futility of this patch.

    Ah, you've added empty lines where there was none... Please don't do this.
I'll ACK the v2 patch, given my comments are addressed.

[...]

MBR, Sergei
