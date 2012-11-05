From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: ping -f is broken in iputils 20121011
Date: Tue, 06 Nov 2012 03:12:36 +0900
Message-ID: <50980194.1000609@linux-ipv6.org>
References: <20121030205249.GA2817@mail> <1TTUJN-000MzR-Tp@internal.tormail.org> <5097841F.2050905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jan Synacek <jsynacek@redhat.com>, msal@tormail.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51307 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754126Ab2KESMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 13:12:38 -0500
In-Reply-To: <5097841F.2050905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Jan Synacek wrote:
> On 10/31/2012 10:11 AM, Mohammad Alsaleh wrote:
>> On Tue, Oct 30, 2012 at 11:52:49PM +0300, Mohammad Alsaleh wrote:
>>> As explained in this bug report(1). ping -f seems to be broken in
>>> iputils 20121011.
>>>
>>> (1) https://bugs.archlinux.org/task/32306
>>
>> Bisected to commit 8feb586c4c6df32badb159947ed233898891aecd
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> Can you please try the attached patch?
> 

I applied this patch.  Thank you.
Mohammad, Thank you for spotting this.

--yoshfuji
