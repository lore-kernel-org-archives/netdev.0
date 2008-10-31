From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: dynamically allocated dst_ops
Date: Fri, 31 Oct 2008 14:34:02 +0100
Message-ID: <490B094A.1080900@fr.ibm.com>
References: <20081030042622.GA21196@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:62388 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbYJaNfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 09:35:22 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m9VDY9Ml558112
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 13:34:09 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9VDY8xh1507340
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 13:34:09 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9VDY8UN005065
	for <netdev@vger.kernel.org>; Fri, 31 Oct 2008 13:34:08 GMT
In-Reply-To: <20081030042622.GA21196@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> They are bogus and should be implanted into struct net directly.

Why they are bogus ?

> In garbage collector hook, just use container_of() (once) to get struct net.
> ->dst_net is useless after that.

Yep, that looks like a better solution.

> I'm going to use this trick for xfrm.
> 
> And if someone has ideas on how to overcome header difficulties, please,
> submit a patch.

