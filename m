From: Mohan Lal Jangir <mohanlal@samsung.com>
Subject: Re: IPv6 connect: Cannot assign requested address
Date: Wed, 19 Nov 2008 12:19:26 +0530
Message-ID: <9F4DDBE4C437408897F01EB2A4FF7AF4@samsung4qkw9nm>
References: <OF8CD6A1B4.53886681-ON88257506.0022E6EA-88257506.00230359@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; reply-type=original; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout5.samsung.com ([203.254.224.35]:38852 "EHLO
	mailout5.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbYKSGtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 01:49:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
          I tried this option also but no luck. I use if_nametoindex to 
assign sin6_scope_id for bind as well as for connect sockaddr_in6.

Not only link local addresses but also site local address have same problem.

Thanks
-Mohan

----- Original Message ----- 
From: "David Stevens" <dlstevens@us.ibm.com>
To: "Mohan Lal Jangir" <mohanlal@samsung.com>
Cc: "Brian Haley" <brian.haley@hp.com>; <netdev@vger.kernel.org>; 
<netdev-owner@vger.kernel.org>
Sent: Wednesday, November 19, 2008 11:52 AM
Subject: Re: IPv6 connect: Cannot assign requested address


> Mohan,
>        When using link-local addresses, you must set sin_scope_id
> to the interface index.
>
>                                                +-DLS
> 

