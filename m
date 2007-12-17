From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER] xt_hashlimit : speedups hash_dst()
Date: Mon, 17 Dec 2007 15:15:48 +0100
Message-ID: <47668494.3080708@trash.net>
References: <4762F78B.80302@cosmosbay.com> <4763AF65.4070200@gmail.com> <4763B4CF.7010908@cosmosbay.com> <20071215.214219.129511362.davem@davemloft.net> <20071217140442.efbpwsc2uhqvnkfp@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	jarkao2@gmail.com, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sami Farin <safari-netfilter@safari.iki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20071217140442.efbpwsc2uhqvnkfp@m.safari.iki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sami Farin wrote:
> On Sat, Dec 15, 2007 at 21:42:19 -0800, David Miller wrote:
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Sat, 15 Dec 2007 12:04:47 +0100
>>
>>> I prefer to let admins chose their size, since it makes attacker life more 
>>> difficult :)
>>>
>>> For example, I can tell you I have a server, were size is between 2.000.000 
>>> and 3.500.000, I dont want to be forced to use 2097152
>>>
>>> A multiply is cheap, at least on current hardware.
>> I agree, and I see nothing wrong with Eric's patch and it
>> should be merged ASAP.
> 
> You could do the same optimization for 
> net/netfilter/nf_conntrack_core.c:__hash_conntrack() , too.


Yes, I already took care of that for conntrack and other netfilter
non-power-of-two hashes.

