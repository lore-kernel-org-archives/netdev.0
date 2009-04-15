From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 11:48:06 +0200
Message-ID: <49E5AD56.6020701@myri.com>
References: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com> <20090415.022809.90182032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, gallatin@myri.com,
	brice@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1830 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752152AbZDOJsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 05:48:19 -0400
In-Reply-To: <20090415.022809.90182032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stanislaw Gruszka <sgruszka@redhat.com>
> Date: Wed, 15 Apr 2009 10:09:37 +0200
>
>   
>> Add LRO alignment initially committed in 621544eb8c3beaa859c75850f816dd9b056a00a3
>> and removed in 0dcffac1a329be69bab0ac604bf7283737108e68 during conversion to
>> multi-slice.
>>
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
>>     
>
> Applied, thanks.
>
> Please, in the future, add the header string of the commit message
> when referencing GIT commits.  When this patch is added to the -stable
> kernel or similar the GIT commit ideas might be different and it
> will be impossible for someone reading your commit message to find
> the referenced commit using only the SHA ID.
>   

I guess we need to send this patch to the stable maintainers since it
should affect 2.6.27, .28 and .29.

> Also, it would great to get this driver converted over to GRO,
> such bugs like this one aren't even possible with GRO :-)
>   

It looks like nobody complains about GRO bugs or performance-problems
anymore so we might indeed look at converting myri10ge for 2.6.31.

Is there a good summary somewhere of why GRO is better, and how to
actually convert drivers?

Brice

