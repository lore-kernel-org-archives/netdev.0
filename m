From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/4 -rev1] Initilize and populate age field
Date: Tue, 07 Aug 2007 10:22:15 +0530
Message-ID: <46B7FA7F.1030700@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:46145 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753260AbXHGEv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 00:51:57 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l773jWCs021028
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 23:45:32 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l774pvIa067810
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 22:51:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l774puuG009157
	for <netdev@vger.kernel.org>; Mon, 6 Aug 2007 22:51:56 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

                Sorry for the late response. I just need few
clarifications.              

               *age = timeval_to_sec(&tv);

         >>>> +        NLA_PUT_U32(skb, RTA_AGE, *age);

         >>> here, what happens if sizeof(time_t) is not 4 ?

              Did you mean that the above should be like this?
               NLA_PUT_U32(skb, RTA_AGE, (unsigned int) *age);

     return tv->tv_sec + (tv->tv_usec ? 1 : 0);

     is much faster

         So can we say that "usec" is *always *< 1000000 ?
            

Regards,
Varun
