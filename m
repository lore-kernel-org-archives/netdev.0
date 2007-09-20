From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: be more selective about FIFO watchdog
Date: Thu, 20 Sep 2007 17:46:01 -0400
Message-ID: <46F2EA19.7040805@pobox.com>
References: <20070920130349.252ecdb9@freepuppy.rosehill>	<46F2DD41.30909@pobox.com> <20070920143046.61fce43b@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34034 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407AbXITVqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 17:46:03 -0400
In-Reply-To: <20070920143046.61fce43b@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 20 Sep 2007 16:51:13 -0400
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> Be more selective about when to enable the ram buffer watchdog code.
>>> It is unnecessary on XL A3 or later revs, and with Yukon FE
>>> the buffer is so small (4K) that the watchdog detects false positives.
>>>
>>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>> With all the sky2 patches flying about, it would be wise to include 
>> notes like "applies to 2.6.23-rc" or "net-2.6.24" after the standard 
>> "---" terminator.
>>
>> is this patch supposed to go on top of the sky2 patches that Linus just 
>> pulled?
>>
>>
> It can go after previous 6 on both 2.6.23-rc and net-2.6.24 (with fuzz)

Is it _needed_ in 2.6.23-rc, Mr. Maintainer?  :)

The answer to that question is not clear to me, given the description 
and code.

	Jeff



