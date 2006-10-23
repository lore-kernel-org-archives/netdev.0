From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Subject: Re: [PATCH] atm: fix horizon init section usage
Date: Sun, 22 Oct 2006 21:32:20 -0700
Message-ID: <453C45D4.6080904@oracle.com>
References: <20061022191309.73e3eacd.randy.dunlap@oracle.com> <20061022.203922.130845181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48301 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1751274AbWJWEbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 00:31:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061022.203922.130845181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Sun, 22 Oct 2006 19:13:09 -0700
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> hrz_init() is called from the probe function, which is __devinit
>> and could be called after init.
>>
>> WARNING: drivers/atm/horizon.o - Section mismatch: reference to .init.text:.hrz_init from .text between '.hrz_probe' (at offset 0x4054) and '.hrz_remove_one'
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> It is only called from hrz_init() and thus shouldn't it be
> thus marked __devinit as well?  That seems to be the right
> way to fix this one.

Oops, I agree.  Want me to send another patch?

-- 
~Randy
