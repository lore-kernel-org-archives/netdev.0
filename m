From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH repost net-next] net: compile renesas directory if
 NET_VENDOR_RENESAS is configured
Date: Tue, 25 Aug 2015 16:04:11 -0700 (PDT)
Message-ID: <20150825.160411.2267064889516069269.davem@davemloft.net>
References: <55DC2899.2050205@cogentembedded.com>
	<55DCDB0D.8060201@cogentembedded.com>
	<20150825225539.GA30202@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, horms+renesas@verge.net.au,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	magnus.damm@gmail.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbbHYXEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 19:04:12 -0400
In-Reply-To: <20150825225539.GA30202@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed, 26 Aug 2015 08:55:39 +1000

> On Wed, Aug 26, 2015 at 12:15:57AM +0300, Sergei Shtylyov wrote:
>> On 08/25/2015 11:34 AM, Sergei Shtylyov wrote:
>> 
>> >>From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> >>
>> >>Currently the renesas ethernet driver directory is compiled if SH_ETH is
>> >>configured rather than NET_VENDOR_RENESAS. Although incorrect that was
>> >>quite harmless as until recently as SH_ETH configured the only driver in
>> >>the renesas directory. However, as of c156633f1353 ("Renesas Ethernet AVB
>> >>driver proper") the renesas directory includes another driver, configured
>> >>by RAVB, and it makes little sense for it to have a hidden dependency on
>> >>SH_ETH.
>> >>
>> >>Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> >>[horms: rewrote changelog]
>> >>Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>> >
>> >    Sorry about missing that when submitting the AVB driver.
>> 
>>    BTW, why against net-next? I consider this a fix.
> 
> I wasn't sure which way to go and decided to err on the side of caution with a
> net-next submission. I have no objections to it being considered for next.

I'll put it in the 'net' tree.

Applied, thanks.
