From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] drivers: net: ethernet: 8390: Kconfig: add H8300H_AKI3068NET
 and H8300H_H8MAX dependancy for NE_H8300
Date: Wed, 04 Sep 2013 10:52:02 +0800
Message-ID: <5226A052.8090806@asianux.com>
References: <522011A1.2080305@asianux.com> <20130830143639.GA16269@windriver.com> <5223F5D2.7050504@asianux.com> <20130903.223720.765149153140271341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, ysato@users.sourceforge.jp,
	keescook@chromium.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:7083 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319Ab3IDCxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:53:07 -0400
In-Reply-To: <20130903.223720.765149153140271341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 10:37 AM, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Mon, 02 Sep 2013 10:20:02 +0800
> 
>> Currently only H8300H_AKI3068NET and H8300H_H8MAX define default
>> I/O base and IRQ values for the NE_H8300 driver.  Hence builds
>> for other H8300H platforms will fail as per below. Since H8300H
>> does not support multi platform builds, we simply limit building
>> the driver to those two platforms specifically.
>>
>> The release error:
>  ...
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> 
> Applied, thanks.
> 
> 

Thank you too.

And h8300 architecture will be remove from Linux kernel (and I am sorry
for forgot to notifying Paul about it),

Do we still need this patch (I am not quite sure, maybe we still need) ?


Thanks.
-- 
Chen Gang
