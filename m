From: Patrick McHardy <kaber@trash.net>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 06:00:40 +0100
Message-ID: <41FDBB78.2050403@trash.net>
References: <41FD2043.3070303@trash.net>	<E1CvSuS-00056x-00@gondolin.me.apana.org.au> <20050131.134559.125426676.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se, akpm@osdl.org,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050131.134559.125426676.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:

>In article <E1CvSuS-00056x-00@gondolin.me.apana.org.au> (at Mon, 31 Jan 2005 15:11:32 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:
>
>
>>Patrick McHardy <kaber@trash.net> wrote:
>>
>>>Ok, final decision: you are right :) conntrack also defragments locally
>>>generated packets before they hit ip_fragment. In this case the fragments
>>>have skb->dst set.
>>>
>>Well caught.  The same thing is needed for IPv6, right?
>>
>
>(not yet confirmed, but) yes, please.
>
We don't need this for IPv6 yet. Once we get nf_conntrack in we
might need this, but its IPv6 fragment handling is different from
ip_conntrack, I need to check first.

Regards
Patrick
