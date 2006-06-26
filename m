From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 4/4] Network namespaces: playing and debugging
Date: Mon, 26 Jun 2006 19:29:57 +0200
Message-ID: <44A01995.20802@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <20060626135537.D28942@castle.nmd.msu.ru> <449FF77D.3080707@fr.ibm.com> <20060626194339.D989@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:60100 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750990AbWFZRaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 13:30:00 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060626194339.D989@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>Do
>>>	exec 7< /proc/net/net_ns
>>>in your bash shell and you'll get a brand new network namespace.
>>>There you can, for example, do
>>>	ip link set lo up
>>>	ip addr list
>>>	ip addr add 1.2.3.4 dev lo
>>>	ping -n 1.2.3.4
>>>

Andrey,

I began to play with your patchset. I am able to connect to 127.0.0.1 
from different namespaces. Is it the expected behavior ?
Furthermore, I am not able to have several programs, running in 
different namespaces, to bind to the same INADDR_ANY:port.

Will these features be included in the second patchset ?

>>
>>Is it possible to setup a network device to communicate with the outside ?
> 
> 
> Such device was planned for the second patchset :)
> I perhaps can send the patch tomorrow.

Cool :)
