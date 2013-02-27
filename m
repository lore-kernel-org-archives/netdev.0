From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 15:24:07 -0500 (EST)
Message-ID: <20130227.152407.610703805329225791.davem@davemloft.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
	<1361991273-30578-1-git-send-email-lee.roberts@hp.com>
	<512E6905.2020808@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lee.roberts@hp.com, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981Ab3B0UYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:24:08 -0500
In-Reply-To: <512E6905.2020808@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 27 Feb 2013 15:13:57 -0500

> On 02/27/2013 01:54 PM, Lee A. Roberts wrote:
>> From: "Lee A. Roberts" <lee.roberts@hp.com>
>>
>> This series of patches resolves several SCTP association hangs
>> observed during
>> SCTP stress testing.  Observable symptoms include communications hangs
>> with
>> data being held in the association reassembly and/or lobby (ordering)
>> queues.
>> Close examination of reassembly/ordering queues may show either
>> duplicated
>> or missing packets.
> 
> Hi Lee
> 
> What changed in this series?  I looked through and they don't look
> different from the prior version?

He fixed the build failure, and he described this at:

http://marc.info/?l=linux-netdev&m=136199143224349&w=2

But yeah he absolutely and positively should have mentioned it here
too.
