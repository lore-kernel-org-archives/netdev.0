From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause
 probe to fail.
Date: Mon, 22 Mar 2010 01:35:20 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFEFED1DB@MNEXMB2.qlogic.org>
References: <m1y6hqdol4.fsf@fess.ebiederm.org>
	<99737F4847ED0A48AECC9F4A1974A4B80CFEFED04B@MNEXMB2.qlogic.org>
	<m11vfic6d0.fsf@fess.ebiederm.org>
 <20100318.222126.27823381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>,
	David Miller <davem@davemloft.net>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:43810 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538Ab0CVGft convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 02:35:49 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
  After discussing this issues with my team, this is fine with Qlogic to remove support of NX_P3_B1.

  You can go ahead with Eric's patch.

  Sorry for all these hiccups.

-Amit Salecha

-----Original Message-----
From: Amit Salecha 
Sent: Friday, March 19, 2010 5:33 PM
To: 'David Miller'; 'ebiederm@xmission.com'
Cc: 'netdev@vger.kernel.org'; Ameen Rahman
Subject: RE: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.

David,
   Eric's initial problem got resolved by using newer firmware (link problem).
   He is facing another problem, mac address are all ff:ff:ff.
   Though this problem goes away with driver reload.

   We had asked for fw dump to analyze this problem in detail.

-Amit Salecha 

-----Original Message-----
From: Amit Salecha 
Sent: Friday, March 19, 2010 11:07 AM
To: 'David Miller'; ebiederm@xmission.com
Cc: netdev@vger.kernel.org; Ameen Rahman
Subject: RE: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.

We are working on this problem, will let you know our decision by end of day.

-Thanks

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Friday, March 19, 2010 10:51 AM
To: ebiederm@xmission.com
Cc: Amit Salecha; netdev@vger.kernel.org; Ameen Rahman
Subject: Re: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 18 Mar 2010 02:43:39 -0700

> Amit Salecha <amit.salecha@qlogic.com> writes:
> 
>> Sorry for all the problem you faced.
>>
>> But you shouldn't add support of device which is not supported.
>> Netxen is now owned by Qlogic. You should first contact Qlogic to solve your problem.
>> Qlogic will take needed action based on problem.
> 
> I'm not adding support.  I am sending a patch removing support for cards
> that do not work with the current driver and have not worked since 2.6.31.

You qlogic folks better resolve this _FAST_ or else I'll
make an executive decision about how to handle this and
I guarentee I'll make a decision that you will not like.

Thanks. :-)
