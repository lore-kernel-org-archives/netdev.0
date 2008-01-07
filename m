From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 5/9][NETNS][IPV6] make bindv6only sysctl per namespace
Date: Mon, 07 Jan 2008 17:36:35 +0100
Message-ID: <47825513.50100@fr.ibm.com>
References: <20080104111226.776105484@localhost.localdomain> <20080104111431.444295890@localhost.localdomain> <47825402.8030504@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: Benjamin Thery <benjamin.thery@bull.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:13033 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755672AbYAGQpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 11:45:39 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id m07Gjbap289218
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 16:45:37 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m07Gjb3H2605224
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 17:45:37 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m07Gjb3N003941
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 17:45:37 +0100
In-Reply-To: <47825402.8030504@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> Daniel,
> 
> The kernel fails to build with this patch applied when CONFIG_SYSCTL=n
> See comment below.
> 
> Daniel Lezcano wrote:
>> This patch moves the bindv6only sysctl to the network namespace
>> structure. Until the ipv6 protocol is not per namespace, the sysctl
>> variable is always from the initial network namespace.

Argh !

Thanks Benjamin to catch this.

I think I have to apologize to Eric, I thought I tested with this option 
off but it wasn't and Eric was right. I will wait a little for feedbacks 
and send a V3.

