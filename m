From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v1 2/2] TCPCT API sockopt update to draft -03
Date: Thu, 13 Jan 2011 12:32:19 -0500
Message-ID: <4D2F3723.9040405@gmail.com>
References: <4D2DE824.10205@gmail.com>	<4D2DEC0A.70608@gmail.com> <20110112105608.793787b2@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110112105608.793787b2@s6510>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/12/11 1:56 PM, Stephen Hemminger wrote:
> On Wed, 12 Jan 2011 12:59:38 -0500
> William Allen Simpson<william.allen.simpson@gmail.com>  wrote:
>
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index e64f4c6..c8f4017 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -185,22 +185,37 @@ struct tcp_md5sig {
>>   #define TCP_COOKIE_PAIR_SIZE	(2*TCP_COOKIE_MAX)
>>
>>   /* Flags for both getsockopt and setsockopt */
>> -#define TCP_COOKIE_IN_ALWAYS	(1<<  0)	/* Discard SYN without cookie */
>> -#define TCP_COOKIE_OUT_NEVER	(1<<  1)	/* Prohibit outgoing cookies,
>> +#define TCPCT_IN_ALWAYS		(1<<  0)	/* Discard SYN without cookie */
>> +#define TCPCT_OUT_NEVER		(1<<  1)	/* Prohibit outgoing cookies,
>
> You end up changing values in kernel userspace API in a way
> that is incompatible with older applications. This is not acceptable.
>
While I agree in principle and argued strongly against it, other
members of the research group (particularly the original project
sponsor) have over-ridden my concerns.  I'm sorry to inform you that
many/most participants don't care much about Linux.

Note that the *bits* are the same, and previously compiled programs
(that don't access more advanced features) should continue to run as
they have in the past.

Even though I'm not paid to work on Linux, I'm doing my best to give you
folks a quick heads up and provide code to rectify the very recent changes
that can be propagated back through the stable tree (to 2.6.33).

As always, what you actually do with my code is up to you....
