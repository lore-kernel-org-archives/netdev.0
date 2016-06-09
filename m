From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] net: ipconfgi: add declaration for ic_addrservaddr
Date: Thu, 9 Jun 2016 13:11:45 +0100
Message-ID: <ab991904-5443-1b2a-cae0-ff9697690f05@codethink.co.uk>
References: <1465470466-11379-1-git-send-email-ben.dooks@codethink.co.uk>
 <57595469.7010708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47024 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbcFIMLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 08:11:51 -0400
In-Reply-To: <57595469.7010708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/16 12:35, Daniel Borkmann wrote:
> On 06/09/2016 01:07 PM, Ben Dooks wrote:
>> The symbol ic_addrservaddr is not static, but has no declaration
>> to match. Since the similar variables are all exported, add this
>> one to the header file as well.
>>
>> This fixes the following warning:
>>
>> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not
>> declared. Should it be static?
>>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
> Well, how about making it actually static if it's only used
> from ipconfig.c ?

The only reason is that I thought someone might want to
use it in the future. I have no particular insight though.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
