From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce
	primary_lazy option
Date: Fri, 14 Aug 2009 12:59:39 +0200
Message-ID: <20090814105938.GE3457@psychotron.englab.brq.redhat.com>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55873 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625AbZHNK75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 06:59:57 -0400
Content-Disposition: inline
In-Reply-To: <4A846C4E.8030509@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 13, 2009 at 09:41:02PM CEST, nicolas.2p.debian@free.fr wrote:
> Jiri Pirko wrote:
>> In some cases there is not desirable to switch back to primary interface when
>> it's link recovers and rather stay wiith currently active one. We need to avoid
>> packetloss as much as we can in some cases. This is solved by introducing
>> primary_lazy option. Note that enslaved primary slave is set as current
>> active no matter what.
>
> May I suggest that instead of creating a new option to better define how
> the "primary" option is expected to behave for active-backup mode, we  
> try the "weight" slave  option I proposed in the thread "alternative to  
> primary" earlier this year ?
>
> http://sourceforge.net/mailarchive/forum.php?thread_name=49D5357E.4020201%40free.fr&forum_name=bonding-devel

This link does not work for me :(

>
> Giving the same "weight" to two different slaves means "chose at random
> on startup and keep the active one until it fails". And if the "at
> random" behavior is not appropriate, one can force the active slave
> using what Jay suggested  (/sys/class/net/bond0/bonding/active).
>
> The proposed "weight" slave's option is able to prevent the slaves from
> flip-flopping, by stating the fact that two slaves share the same  
> "primary" level, and may provide several other enhancements as described  
> in the thread.
>

Although I cannot reach the thread, this looks interesting. But I'm not sure it
has real benefits over primary_lazy option (and it doesn't solve initial curr
active slave setup)

Jirka

> Hence, it is a more general configuration interface than what you  
> proposed. I must admit that despite the fact that I suggested this in  
> april, I didn't posted any patch for it until now. Unfortunately,  
> I'didn't had time for it and probably not the proper skills anyway :-).
>
> 	Nicolas.
>
>
>
