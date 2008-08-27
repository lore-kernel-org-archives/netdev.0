From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 17:55:15 +0300
Message-ID: <1ba2fa240808270755t2f3d0c28rcb874011f5540ef3@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
	 <1219831828.3891.3.camel@johannes.berg>
	 <1ba2fa240808270434y1589761xd2ff0a48c2e99033@mail.gmail.com>
	 <200808271510.35950.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Marcel Holtmann" <holtmann@linux.intel.com>,
	"David Miller" <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael Buesch" <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:27675 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbYH0OzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 10:55:17 -0400
Received: by ug-out-1314.google.com with SMTP id c2so937317ugf.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 07:55:16 -0700 (PDT)
In-Reply-To: <200808271510.35950.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 4:10 PM, Michael Buesch <mb@bu3sch.de> wrote:
> On Wednesday 27 August 2008, Tomas Winkler wrote:
>> > should use Linux upstream as your development tree and then branch off
>> > of that for the internal stabilisation trees you need for other
>> > customers, rather than having some sort of internal development tree and
>> > branching out Linux upstream as you appear to work.
>>
>> Unfortunately fixing bugs on stable branch take precedence  of
>> adjusting to new API on development branch that someone decided to do.
>>  I wanted to work directly on wireless testing but it was broken over
>> an over and I have only limited resources more in testing then in
>> development I just had to branch out to be ready with the driver when
>> HW is out. People just check the immediate impact of they fix the
>> don't test for collateral damage and this is understandable an
>> individual developer doesn't have lab with IBSS, BSS, AP, etc setups.
>
> I think it would be an advantage for you to develop in wireless-testing
> and use wireless-2.6 and probably additionally some internal trees as
> stable trees. Like everybody else does it.

I'm not sure what you are taking about, we did post patches to
wireless-testing, the driver for 5000 HW  is working in 2.6.27-rc4 I
personally use it every day.  I'm sending bug fixes, like this seris
of patches is direct answer to bugs that were discovered very
recently, I'm not sure what's everybody problem here.

> The advantage is simple: You get more people testing your code.

We fixed bugs in wireless-testing/mac80211 that were there for months
just because we are only one that do any comprehensive validation. I
don't  want insult anyone and I really exaggeration here but
sometimes I have feeling that more people are breaking the code.

Tomas
