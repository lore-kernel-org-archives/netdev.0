From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sat, 07 May 2011 19:38:41 +0100
Message-ID: <472A3314CA89E2E5270E320A@Ximines.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:52126 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755919Ab1EGSio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 14:38:44 -0400
In-Reply-To: <1304785589.3207.5.camel@edumazet-laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 7 May 2011 18:26:29 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:

># time rmmod dummy
>
> real	0m0.111s
> user	0m0.000s
> sys	0m0.000s
>
>
> This removed my two dummy0/dummy1 devices.

rmmod dummy even with numdummies=100 does only one synchronize_net() and
is quick (0.8ms).

-- 
Alex Bligh
