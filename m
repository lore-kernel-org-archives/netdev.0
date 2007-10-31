From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 22:37:11 +0100
Message-ID: <4728F587.2060008@fr.ibm.com>
References: <4728D54F.2080208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:55865 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386AbXJaVk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 17:40:28 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l9VLeG2M302968
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:40:16 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VLeGAj2130006
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:40:16 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VLe0mj006032
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 21:40:00 GMT
In-Reply-To: <4728D54F.2080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Currently we have the NET_NS config option, but the only change it 
> makes is just return ERR_PTR(-EINVAL) inside the cloning call thus
> introducing a bunch of a dead code and making the reference counting
> unneeded. This is not very good.
> 
> So clean the net_namespace.c to fix this.
> 
> I have sent a set of patches to Andrew to make similar thing for
> other namespaces, which introduces the NAMESPACES option to turn
> all the namespaces off at once (to make embedded people suffer
> less). So after that stuff is in, there will be some more patches 
> to tie all this together.
> 
> What is to be done after this set is to make the register_pernet_xxx
> stuff smaller. Currently this code weights approximately 500 bytes, 
> so it worths reducing it, but I haven't found a good solution yet.

Did you had time to check the impact of your patch with the rest of the 
network namespaces not yet included in mainline, belonging to Eric's git 
tree ?

ps: can you cc' emails concerning the network namespace to the 
containers mailing list too ? thx.
