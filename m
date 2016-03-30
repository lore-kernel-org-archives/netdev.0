From: David Miller <davem@davemloft.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Wed, 30 Mar 2016 12:38:21 -0400 (EDT)
Message-ID: <20160330.123821.328761526754742195.davem@davemloft.net>
References: <56F9941A.3080501@candelatech.com>
	<56FAAA6D.3070806@candelatech.com>
	<1459329252.2055.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	herbert@gondor.apana.org.au, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459329252.2055.1.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 30 Mar 2016 11:14:12 +0200

> On Tue, 2016-03-29 at 09:16 -0700, Ben Greear wrote:
>> Looks like rhashtable has too much policy in it to properly deal with
>> cases where there are too many hash collisions, so I am going to work
>> on reverting it's use in mac80211.
> 
> I'm not really all that happy with that approach - can't we fix the
> rhashtable? It's a pretty rare corner case that many keys really are
> identical and no kind of hash algorithm, but it seems much better to
> still deal with it than to remove the rhashtable usage and go back to
> hand-rolling something.

Yeah reverting seems like a really idiotic way to deal with the issue.
