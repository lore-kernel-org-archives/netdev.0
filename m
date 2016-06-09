From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] net: ipconfgi: add declaration for ic_addrservaddr
Date: Thu, 09 Jun 2016 14:15:43 +0200
Message-ID: <57595DEF.8010105@iogearbox.net>
References: <1465470466-11379-1-git-send-email-ben.dooks@codethink.co.uk> <57595469.7010708@iogearbox.net> <ab991904-5443-1b2a-cae0-ff9697690f05@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Dooks <ben.dooks@codethink.co.uk>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48385 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbcFIMQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 08:16:17 -0400
In-Reply-To: <ab991904-5443-1b2a-cae0-ff9697690f05@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2016 02:11 PM, Ben Dooks wrote:
> On 09/06/16 12:35, Daniel Borkmann wrote:
>> On 06/09/2016 01:07 PM, Ben Dooks wrote:
>>> The symbol ic_addrservaddr is not static, but has no declaration
>>> to match. Since the similar variables are all exported, add this
>>> one to the header file as well.
>>>
>>> This fixes the following warning:
>>>
>>> net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not
>>> declared. Should it be static?
>>>
>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>
>> Well, how about making it actually static if it's only used
>> from ipconfig.c ?
>
> The only reason is that I thought someone might want to
> use it in the future. I have no particular insight though.

Usual policy is that if such thing is required, then it can be
exported along with the code that is making use of it from elsewhere.

Thanks,
Daniel
