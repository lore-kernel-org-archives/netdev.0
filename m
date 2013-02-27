From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 0/4] sctp: fix association hangs due to reassembly/ordering
 logic
Date: Wed, 27 Feb 2013 15:49:27 -0500
Message-ID: <512E7157.4060200@redhat.com>
References: <1361889376-22171-1-git-send-email-lee.roberts@hp.com> <1361991273-30578-1-git-send-email-lee.roberts@hp.com> <512E6905.2020808@redhat.com> <20130227.152407.610703805329225791.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lee.roberts@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443Ab3B0Uta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 15:49:30 -0500
In-Reply-To: <20130227.152407.610703805329225791.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2013 03:24 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Wed, 27 Feb 2013 15:13:57 -0500
>
>> On 02/27/2013 01:54 PM, Lee A. Roberts wrote:
>>> From: "Lee A. Roberts" <lee.roberts@hp.com>
>>>
>>> This series of patches resolves several SCTP association hangs
>>> observed during
>>> SCTP stress testing.  Observable symptoms include communications hangs
>>> with
>>> data being held in the association reassembly and/or lobby (ordering)
>>> queues.
>>> Close examination of reassembly/ordering queues may show either
>>> duplicated
>>> or missing packets.
>>
>> Hi Lee
>>
>> What changed in this series?  I looked through and they don't look
>> different from the prior version?
>
> He fixed the build failure, and he described this at:
>
> http://marc.info/?l=linux-netdev&m=136199143224349&w=2
>
> But yeah he absolutely and positively should have mentioned it here
> too.
>

Thanks.  Didn't realize it was just a build error.  Was looking for 
functionality change.

-vlad
