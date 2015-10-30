From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: move inline functions to the header file
Date: Sat, 31 Oct 2015 02:09:15 +0300
Message-ID: <5633F89B.6000702@cogentembedded.com>
References: <4254119.qJUdUQCUqs@wasted.cogentembedded.com>
 <20150407.152249.360575010614186977.davem@davemloft.net>
 <55242F5F.2060409@cogentembedded.com>
 <20150407.153337.1789757717574323514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150407.153337.1789757717574323514.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/07/2015 10:33 PM, David Miller wrote:

>>>> The explicitly inline functions belong to the header files, so move
>>>> cpu_to_edmac() and edmac_to_cpu() into the driver header.
>>
>>>> While at it, make these functions return 'u32' instead of '__u32'.
>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>>> Then... ummm... remove the inline keyword?
>>
>>> If it's not used anywhere else, that's the thing to do.
>>
>>     Results in more code, as I noted in the patch posting that you skipped
>>     when replying. At least with gcc 4.7.
>
> That's a compiler bug.

    Even worse, these functions support the BE mode which never was used and 
never worked correctly. I'll just try to remove them altogether.

MBR, Sergei

