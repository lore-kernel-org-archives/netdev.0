From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: move inline functions to the header file
Date: Tue, 07 Apr 2015 15:33:37 -0400 (EDT)
Message-ID: <20150407.153337.1789757717574323514.davem@davemloft.net>
References: <4254119.qJUdUQCUqs@wasted.cogentembedded.com>
	<20150407.152249.360575010614186977.davem@davemloft.net>
	<55242F5F.2060409@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55242F5F.2060409@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Tue, 07 Apr 2015 22:26:23 +0300

> Hello.
> 
> On 04/07/2015 10:22 PM, David Miller wrote:
> 
>>> The explicitly inline functions belong to the header files, so move
>>> cpu_to_edmac() and edmac_to_cpu() into the driver header.
> 
>>> While at it, make these functions return 'u32' instead of '__u32'.
> 
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
>> Then... ummm... remove the inline keyword?
> 
>> If it's not used anywhere else, that's the thing to do.
> 
>    Results in more code, as I noted in the patch posting that you skipped
>    when replying. At least with gcc 4.7.

That's a compiler bug.
