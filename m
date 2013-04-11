From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Wed, 10 Apr 2013 21:53:35 -0700
Message-ID: <516641CF.4020101@us.ibm.com>
References: <1365501445-9712-1-git-send-email-amwang@redhat.com> <1365530913.29336.50.camel@oc1677441337.ibm.com> <1365646215.25993.3.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:50136 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab3DKExf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 00:53:35 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Thu, 11 Apr 2013 00:53:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 14C2BC9001A
	for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 00:53:32 -0400 (EDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3B4rVKo327310
	for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 00:53:32 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3B4rTMT011519
	for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 22:53:30 -0600
In-Reply-To: <1365646215.25993.3.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2013 7:10 PM, Cong Wang wrote:
>> - when source and destination endpoints belonging to different vni's
>>    are on 2 different bridges on the same host. encap bypass is done
>>    in this scenario by checking if rt_flags has RTCF_LOCAL set. I think
>>    you must be hitting this path and the following patch should fix
>>    it by only doing bypass if the source and dest devices belong to
>>    the same net. Can you try it and see if it fixes your tests?
> I just tested it, unfortunately it doesn't work, the bug still exists.
>
> If you need any other info, please let me know.
So does it mean that you are hitting the if condition that does encap 
bypass
even afterthe net_eq() check? Do the tests pass If you comment out the 
'if' block?

Can you share your test config/scripts so that i can try out your setup if
it is not toocomplicated?

Thanks
Sridhar
