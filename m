From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Tue, 22 Jul 2003 15:59:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1DC1E3.4060504@us.ibm.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>	<Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com> <20030722.182545.97160275.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030722.182545.97160275.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I guess you are talking about the statistics part. This is fine with me.

thx,

- KK

YOSHIFUJI Hideaki / ???? wrote:
> In article <Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com> (at Tue, 22 Jul 2003 14:50:21 -0700 (PDT)), Krishna Kumar <krkumar@us.ibm.com> says:
> 
> 
>>I didn't add the statistics, though it can be implemented :
>>RTA_PUT(skb, IFLA_INET6_STATS, sizeof(idev->stats.icmpv6),
>>		&idev->stats.icmpv6[0]);
>>RTA_PUT(skb, IFLA_INET6_STATS, sizeof(idev->stats.icmpv6),
>>                &idev->stats.icmpv6[1]);
>>something like that would work ?
> 
> 
> I'd like to do this later, if you don't mind.
> 
> --yoshfuji
> 
