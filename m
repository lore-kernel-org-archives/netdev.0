From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: kernel newbie question on kernel panic
Date: Mon, 21 Jul 2008 18:07:25 +0200
Message-ID: <4884B43D.2080205@fr.ibm.com>
References: <4474723F928CA640ADB2172099AEAB111B603F@exalfa.stromtelecom.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Filka Michal <Michal.Filka@sitronicsts.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:47349 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbYGUQIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:08:30 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6LG7ZZj562518
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 16:07:35 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6LG7ZtB3731672
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:07:35 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6LG7YBJ005952
	for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 18:07:34 +0200
In-Reply-To: <4474723F928CA640ADB2172099AEAB111B603F@exalfa.stromtelecom.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Filka Michal wrote:
> Hi all,
> 
> I try to create my first kernel module.
> I have following problem. I have a function rp ... interesting part
> follows (just some initialization is ommited - nothing special - the
> function is just a skeleton)
> 
> int rp( struct sk_buff ** skb)
> {
> 	_filter_rule * rule = NULL;
> 
> ...
> 
> 	rule = placebo();
> -->	if( rule == NULL)
> 		printk( KERN_DEBUG "null rule\n");
> 	return 1;
> }
> 
> The rp is called (subsequently) in netfilter (prerouting) hook context,
> so as far as I know it runs in a SoftIRQ.
> 
> The placebo function does nothing - just returns NULL. The problem is in
> line selected (-->).Everything goes until I try to somehow access
> returned value. The access raises kernel panic, seems that some page
> fault happent. If I comment out the line bellow selected (the test), no
> kernel panic happens.
> 
> Questions are:
> - why the page fault happens (some trouble in memory usage, or so?)
> - how to avoid it?
> 
> Thanks for any help
> Michal Filka

What is the definition of _filter_rule ?
