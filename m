From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] rhashtable: fix missing header
Date: Sun, 4 Jan 2015 17:24:31 +0800
Message-ID: <54A906CF.7000309@windriver.com>
References: <1420356309-7382-1-git-send-email-ying.xue@windriver.com> <20150104091908.GA15305@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47465 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbADJY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 04:24:58 -0500
In-Reply-To: <20150104091908.GA15305@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2015 05:19 PM, Thomas Graf wrote:
> On 01/04/15 at 03:25pm, Ying Xue wrote:
>> Fixup below build error:
>>
>> include/linux/rhashtable.h: At top level:
>> include/linux/rhashtable.h:118:34: error: field ???mutex??? has incomplete type
> 
> Just wondering, is this your new code that didn't compile? The code
> compiled fine for me for the existing users.
> 

When I did below patch, I met the build error.

http://patchwork.ozlabs.org/patch/425149/

By the way, please help to review the patch if you have time :)

Thanks!

Regards,
Ying

>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> 
> Fixes: 97defe1e ("rhashtable: Per bucket locks & deferred expansion/shrinking")
> Acked-by: Thomas Graf <tgraf@suug.ch>
> 
> 
> 
