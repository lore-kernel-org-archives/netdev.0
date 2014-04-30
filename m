From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V7 net-next 4/7] xen-netback: Correctly clean up after
 queue initialisation error.
Date: Wed, 30 Apr 2014 17:46:05 +0100
Message-ID: <536128CD.3010705@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com> <1398778035-26233-5-git-send-email-andrew.bennieston@citrix.com> <20140430144954.GA19082@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32863 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbaD3QqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 12:46:06 -0400
In-Reply-To: <20140430144954.GA19082@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 15:49, Wei Liu wrote:
> On Tue, Apr 29, 2014 at 02:27:12PM +0100, Andrew J. Bennieston wrote:
>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>
>> Multiple queues were introduced in the previous patch, but if the
>> initialisation of a queue failed, earlier queues would not be cleaned
>> up. This patch adds cleanup logic for this scenario, making use of code
>> from the regular teardown sequence.
>>
>
> Shouldn't this patch be folded into that "previous patch" which
> introduced this problem? I see you did this for netfront patch already.
>
> Wei.
>
The netfront patch included this from the beginning; I simply forgot to 
implement it in netback. I added it as a separate patch to make it 
easier to review, but I can certainly merge it in with the other one 
(and indeed should do so to maintain correct behaviour e.g. during a 
bisect).

I think I'd rather receive comments on this separately, then if 
necessary either repost the series with this folded into the relevant 
patch for final merge, or post V8 with it folded after comments have 
been addressed. Especially since this patch series already has some very 
long patches...

Andrew.
