From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [patch net] net: correct check in dev_addr_del()
Date: Sat, 12 Jan 2013 21:39:06 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1301122134100.15558@nerf07.vanv.qr>
References: <1352897464-832-1-git-send-email-jiri@resnulli.us>  <1352902715.4497.3.camel@edumazet-glaptop>  <20121114142941.GA2531@minipsycho.brq.redhat.com> <1352903939.4497.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@vyatta.com,
	john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:53905 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059Ab3ALUjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2013 15:39:07 -0500
In-Reply-To: <1352903939.4497.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2012-11-14 15:38, Eric Dumazet wrote:
>> 
>> bug introduced by:
>> 
>> commit a748ee2426817a95b1f03012d8f339c45c722ae1
>> Author: Jiri Pirko <jpirko@redhat.com>
>> Date:   Thu Apr 1 21:22:09 2010 +0000
>> 
>>     net: move address list functions to a separate file
>
>Good, the usual way is then to add in the changelog :
>
>Bug added in commit a748ee242681
>(net: move address list functions to a separate file)
>
>(No need to give the author/date, and we can shorten the SHA1 to 10 or
>12 digits)

A shortened hash value is however not truly future-proof. I recommend
using `git describe` or `git describe --contains`, as that is
unambiguous into the future and shows a related version. In case of
a748ee, that would be v2.6.35-rc1~473^2~602, which immediately tells
us that the bug has been in tarballs since 2.6.35-rc1.
