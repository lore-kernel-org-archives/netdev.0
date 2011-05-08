From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 14:14:35 +0100
Message-ID: <874CAEA33BC0278D3E85DFBB@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>
 <1304770926.2821.1157.camel@edumazet-laptop>
 <0F4A638C2A523577CDBC295E@Ximines.local>
 <1304785589.3207.5.camel@edumazet-laptop>
 <178E8895FB84C07251538EF7@Ximines.local>
 <1304793174.3207.22.camel@edumazet-laptop>
 <1304793749.3207.26.camel@edumazet-laptop>
 <1304838742.3207.45.camel@edumazet-laptop>
 <F57561A93EFF5E88729A8D53@nimrod.local>
 <20110508124428.GJ2641@linux.vnet.ibm.com>
 <6A6F17150A046D2D2670724D@nimrod.local>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Alex Bligh <alex@alex.org.uk>
To: Alex Bligh <alex@alex.org.uk>, paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:56166 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753340Ab1EHNOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 09:14:39 -0400
In-Reply-To: <6A6F17150A046D2D2670724D@nimrod.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 8 May 2011 14:06:07 +0100 Alex Bligh <alex@alex.org.uk> wrote:

> Add to that the fact that there are 2 x synchronize_sched() and one
> rcu_barrier() per interface removal. If I ignore your IRQ idea, that's
> 6 x 3 = 18ms per interface removal at CONFIG_HZ=10, 180ms at
> CONFIG_HZ=100.

Aargh I mean:

6 x 3 = 18ms per interface removal at CONFIG_HZ=1000, 180ms at
CONFIG_HZ=100.


-- 
Alex Bligh
