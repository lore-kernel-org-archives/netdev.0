From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] sctp: fix association hangs due to
 reassembly/ordering logic
Date: Wed, 27 Feb 2013 14:43:20 -0500 (EST)
Message-ID: <20130227.144320.1686689616982948637.davem@davemloft.net>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com>
	<1361991273-30578-1-git-send-email-lee.roberts@hp.com>
	<512E6052.6050301@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lee.roberts@hp.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916Ab3B0TnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 14:43:22 -0500
In-Reply-To: <512E6052.6050301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 27 Feb 2013 20:36:50 +0100

> On 02/27/2013 07:54 PM, Lee A. Roberts wrote:
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
> Just nitpicking here ... all of your 4 patches have the same first
> paragraph,
> which can actually be left out completely if it is already in your
> patch cover
> letter stated.

Right because I can create a merge commit for the series when I apply
it and put that text there.
