From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [PATCH 3/9] network namespaces: playing and debugging
Date: Thu, 17 Aug 2006 12:30:27 +0400
Message-ID: <44E42923.3090806@sw.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060815184843.A2882@castle.nmd.msu.ru> <20060816094641.61190ee9@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:54058 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S932446AbWHQI3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 04:29:20 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060816094641.61190ee9@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>Temporary code to play with network namespaces in the simplest way.
>>Do
>>        exec 7< /proc/net/net_ns
>>in your bash shell and you'll get a brand new network namespace.
>>There you can, for example, do
>>        ip link set lo up
>>        ip addr list
>>        ip addr add 1.2.3.4 dev lo
>>        ping -n 1.2.3.4
>>
>>Signed-off-by: Andrey Savochkin <saw@swsoft.com>
> 
> 
> NACK, new /proc interfaces are not acceptable.

As you can find from the comment this patch is just for playing
with network namespace.

Kirill

