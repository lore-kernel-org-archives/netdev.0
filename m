From: Mohan Lal Jangir <mohanlal@samsung.com>
Subject: Re: IPv6 connect: Cannot assign requested address
Date: Wed, 19 Nov 2008 14:31:23 +0530
Message-ID: <BEEFD443871A47B490567063537F0E13@samsung4qkw9nm>
References: <OFD4F0D743.0BEB65A4-ON88257506.002CC80B-88257506.002CD173@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; reply-type=original; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:14022 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbYKSJBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 04:01:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Found the problem :)
my tcp_client was choosing :: as source address in spite of -s option.

Thanks for you inputs.
-Mohan

----- Original Message ----- 
From: "David Stevens" <dlstevens@us.ibm.com>
To: "Mohan Lal Jangir" <mohanlal@samsung.com>
Cc: "Brian Haley" <brian.haley@hp.com>; <netdev@vger.kernel.org>; 
<netdev-owner@vger.kernel.org>
Sent: Wednesday, November 19, 2008 1:39 PM
Subject: Re: IPv6 connect: Cannot assign requested address


> Can you post the code for tcp_client?
>
>                        +-DLS
> 

