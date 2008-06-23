From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] iproute2: add support for IFLA_NET_NS_PID in ip link
 v2
Date: Mon, 23 Jun 2008 10:08:13 +0200
Message-ID: <485F59ED.2080404@fr.ibm.com>
References: <20080620090734.144305411@theryb.frec.bull.fr> <20080620092109.551812772@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Thery <benjamin.thery@bull.net>, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:12973 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953AbYFWIIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 04:08:25 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m5N88NP1031718
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 08:08:23 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5N88NKh2109598
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 09:08:23 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5N88H7h002785
	for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 09:08:18 +0100
In-Reply-To: <20080620092109.551812772@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> Ah, ah, of course I forgot to refresh the patch before sending it. :)
> There was still a small typo in the patch: a '}' was put instead of 
> a '|' in 'ip link' usage string. 
> 
> Here is the updated patch.
> Sorry for this.
> 
> Benjamin
> 
> Description:
> ------------
> 
> This patch adds support for the IFLA_NET_NS_PID type. It is used to 
> move network devices between network namespaces.
> 
> The syntax is: 
> ip link set DEVICE netns PID
> 
> PID is the pid of a process in the target network namespace.
> 
> (Daniel Lezcano is the original author). 
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Hi Stephen,

we posted this patch several times and we had no response.
I suppose you are very busy and you had no time to answer.
Can you briefly tell us what do you plan to do with this patch ?


Thanks
   -- Daniel

