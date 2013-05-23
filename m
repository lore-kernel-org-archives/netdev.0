From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: fix kernel panic with icmp_dest_unreach
Date: Thu, 23 May 2013 08:53:29 -0700
Message-ID: <1369324409.3301.382.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	   <1369170063.3301.251.camel@edumazet-glaptop>
	 <519C839E.1000309@rcs-rds.ro>  <1369222666.3301.304.camel@edumazet-glaptop>
	 <519CB0D3.8000406@rcs-rds.ro> <1369230739.3301.334.camel@edumazet-glaptop>
	 <519CE6F0.3040703@rcs-rds.ro> <519DD7A4.9090801@rcs-rds.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:50398 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758360Ab3EWPxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 11:53:31 -0400
Received: by mail-pd0-f174.google.com with SMTP id 3so1248973pdj.19
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 08:53:31 -0700 (PDT)
In-Reply-To: <519DD7A4.9090801@rcs-rds.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-23 at 11:47 +0300, Daniel Petre wrote:

> 
> Hello again Eric,
> we applied the little patch from:
> http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
> we have flapped the link few times and everything recovered smooth.
> 

Thats a very good catch, now we have to fix the bug at the right place.
