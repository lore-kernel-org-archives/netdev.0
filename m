From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH 0/6 net-next] rhashtable fixes
Date: Wed, 4 Feb 2015 10:32:36 +0800
Message-ID: <54D184C4.4090501@windriver.com>
References: <cover.1422576760.git.tgraf@suug.ch> <54CB4A95.9060000@windriver.com> <20150130092911.GA2313@casper.infradead.org> <54CB5563.9080000@windriver.com> <20150203172113.GC25410@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40980 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487AbbBDCdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 21:33:13 -0500
In-Reply-To: <20150203172113.GC25410@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2015 01:21 AM, Thomas Graf wrote:
> On 01/30/15 at 05:56pm, Ying Xue wrote:
>> On 01/30/2015 05:29 PM, Thomas Graf wrote:
>>> Right, I see the same soft lockup. Interestingly I cannot trigger it
>>> with the rht test code. I can only trigger it with your Netlink socket
>>> creation stress test. It is definitely related to the deferred worker,
>>> when I disable growing, then the bug disappears.
>>
>> Yes, when I disable expansion, the soft lockup also disappears too.
> 
> I have found the last remaining race and can now run your test
> program successfully in an endless loop.
> 
> I will resubmit a v2 of this series.
> 
> 

Thanks! Once I receive your updates, I will test them again.

Regards,
Ying
