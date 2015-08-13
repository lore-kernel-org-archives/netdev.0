From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] mpls: multipath support
Date: Wed, 12 Aug 2015 19:07:18 -0700
Message-ID: <55CBFBD6.50603@cumulusnetworks.com>
References: <1439329548-50935-1-git-send-email-roopa@cumulusnetworks.com> <55CB82A6.8070800@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ebiederm@xmission.com, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34070 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbbHMCHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 22:07:21 -0400
Received: by pawu10 with SMTP id u10so26657018paw.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 19:07:21 -0700 (PDT)
In-Reply-To: <55CB82A6.8070800@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/12/15, 10:30 AM, Robert Shearman wrote:
> On 11/08/15 22:45, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch series adds multipath support to mpls routes.
>>
>> resembles ipv4 multipath support. The multipath route nexthop
>> selection algorithm is the same code as in ipv4 fib code.
>>
>> I understand that the multipath algorithm in ipv4 is undergoing
>> some changes and will move mpls to similar algo if applicable once
>> those get merged.
>
> Is it necessary for the mpls patch selection algorithm to closely 
> resemble the ipv4 one? 
No, It is not necessary. I picked that because it was already there. And 
I see that ipv4 is also getting some new multipath algorithms
(https://marc.info/?l=linux-api&m=143457208315573&w=2). I wanted to move 
to the new RT_MP infra if that becomes applicable in the future.

> A flow based algorithm would be much better for traffic that is 
> sensitive to re-ordering (e.g TCP, L2VPN) and IMHO we should do this 
> from the start for MPLS.
>
> I've also been looking at implementing this functionality. I've got a 
> set of patches for this that I can send if you'd like.

Definitely. But, It seems like you can also submit incremental patches 
to mine. You can replace the current algo with a hash based with your 
patches.
If that does not work for you and if you want me to merge with this 
series that works too.

Thanks!,
Roopa
