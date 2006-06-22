From: Jeff Garzik <jeff@garzik.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream inclusion
Date: Thu, 22 Jun 2006 17:35:30 -0400
Message-ID: <449B0D22.8030406@garzik.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176862@AVEXCH1.qlogic.org> <20060622142217.0abfe030.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ron Mercer <ron.mercer@qlogic.com>, Linux-Driver@qlogic.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:43226 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S932656AbWFVVjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 17:39:05 -0400
Received: from mail.dvmed.net (srv5.dvmed.net [207.36.208.214])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k5MLckcg021182
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 21:38:59 GMT
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060622142217.0abfe030.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> "Ron Mercer" <ron.mercer@qlogic.com> wrote:
>> Thanks for your feedback.  I've fixed everything you mentioned with the
>> exception of the code below.  I need to swap every other byte pair of my
>> nvram mac address for big endian systems.  Everything else I tried was
>> more messy.  Did you have anything specific in mind?
> 
> Nope, it was more a question for the other netdev developers.  If nobody
> can point at a library function or something then fine, leave it as-is.

It seems sane to me.  The kernel doesn't have a standard le48_to_cpu() 
and cpu_to_le48()...

	Jeff



