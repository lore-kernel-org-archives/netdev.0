From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Wed, 28 Jun 2006 18:34:33 +0400
Message-ID: <44A29379.6060609@sw.ru>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <449FF5AE.2040201@fr.ibm.com> <44A28964.2090006@fr.ibm.com> <20060628183015.B31885@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>,
	herbert@13thfloor.at, devel@openvz.org, sam@vilain.net,
	ebiederm@xmission.com, viro@ftp.linux.org.uk, alexey@sw.ru,
	Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:62493 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1423366AbWF1Of7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 10:35:59 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060628183015.B31885@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>Structures related to IPv4 rounting (FIB and routing cache)
>>>>are made per-namespace.
>>
>>Hi Andrey,
>>
>>if the ressources are private to the namespace, how do you will handle 
>>NFS mounted before creating the network namespace ? Do you take care of 
>>that or simply assume you can't access NFS anymore ?
> 
> 
> This is a question that brings up another level of interaction between
> networking and the rest of kernel code.
> Solution that I use now makes the NFS communication part always run in
> the root namespace.  This is discussable, of course, but it's a far more
> complicated matter than just device lists or routing :)
if we had containers (not namespaces) then it would be also possible to 
run NFS in context of the appropriate container and thus each user could 
  mount NFS itself with correct networking context.

it's another thing which ties subsytems and makes namespaces ugly :/

Kirill
