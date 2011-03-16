From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: net-next-2.6 status...
Date: Wed, 16 Mar 2011 08:38:03 +0100
Message-ID: <20110316073803.GB2780@psychotron.redhat.com>
References: <20110315.160124.104058374.davem@davemloft.net>
 <20110316065008.GA2780@psychotron.redhat.com>
 <20110316.000251.189704695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	linville@tuxdriver.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110316.000251.189704695.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Mar 16, 2011 at 08:02:51AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Wed, 16 Mar 2011 07:50:09 +0100
>
>>>Jiri, I know there is your patch set there, but I think you and Changli
>>>still need to go back and forth one more time wrt. orig_dev semantics.
>>>Since you have been posting this patch set for some time I'm still
>>>willing to apply it for this merge window, but please make haste and
>>>work out the remaining discussion.  Thank you.
>> 
>> Dave, you can apply the rest of the series and leave only the first
>> patch (af_packet) out. There's no dependency. We will figure out things
>> around origdev later.
>
>I was about to do that but I've found other problems.
>
>You cannot make the modifications you make to linux/if.h, those
>interface flags are visible to userspace.

What do you suggest? To remove unused flags and leave gaps there or to
not to remove the flags at all?

Thanks.

Jirka
