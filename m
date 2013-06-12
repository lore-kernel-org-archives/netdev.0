From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-06-06
Date: Wed, 12 Jun 2013 00:07:11 -0700 (PDT)
Message-ID: <20130612.000711.759531077550828193.davem@davemloft.net>
References: <20130606190929.GB18827@tuxdriver.com>
	<20130611.222706.1492583255605214982.davem@davemloft.net>
	<1371018409.8601.2.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371018409.8601.2.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 12 Jun 2013 08:26:49 +0200

> On Tue, 2013-06-11 at 22:27 -0700, David Miller wrote:
>> From: "John W. Linville" <linville@tuxdriver.com>
>> Date: Thu, 6 Jun 2013 15:09:30 -0400
>> 
>> > Johannes Berg (2):
>> >       mac80211: constify ieee802_11_parse_elems() argument
>> 
>> Such cleanups are absolutely, positively, not appropriate at this
>> time.
> 
> My other fix depends on this to not have a const warning. I can add a
> cast to pretend the input isn't const at this point, but that seemed
> like a bad idea as well.

I would combine the two changes into one commit, because then this
necessity is clear and you can even explain this in the commit message
so that there is no argument about the justification.

Thanks.
