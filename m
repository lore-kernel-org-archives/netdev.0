From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: ipv6: tcp: fix potential use after free in tcp_v6_do_rcv
Date: Wed, 04 Sep 2013 00:25:46 +0200
Message-ID: <522661EA.2090506@redhat.com>
References: <1378229352-9779-1-git-send-email-dborkman@redhat.com> <1378230513.7360.37.camel@edumazet-glaptop> <20130903194620.GE8262@mail.gmail.com> <1378240517.7360.41.camel@edumazet-glaptop> <20130903215915.GF8262@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	Jiri Benc <jbenc@redhat.com>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754129Ab3ICWZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 18:25:55 -0400
In-Reply-To: <20130903215915.GF8262@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 11:59 PM, Jean Sacren wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Sep 2013 13:35:17 -0700
>>
>> How did you get your conclusion ?
>
> If one changes one line of code, doesn't one own that line?

The question is not about who currently "owns" the line, but who
first *introduced* an error.
