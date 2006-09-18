From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 4/9] network namespaces: socket hashes
Date: Mon, 18 Sep 2006 17:12:49 +0200
Message-ID: <450EB771.9080609@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184844.A2882@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:13106 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751761AbWIRPMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 11:12:49 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8IFCmpp067740
	for <netdev@vger.kernel.org>; Mon, 18 Sep 2006 15:12:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8IFF1JX1970266
	for <netdev@vger.kernel.org>; Mon, 18 Sep 2006 16:15:01 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8IFCkl2032453
	for <netdev@vger.kernel.org>; Mon, 18 Sep 2006 16:12:47 +0100
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060815184844.A2882@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> Socket hash lookups are made within namespace.
> Hash tables are common for all namespaces, with
> additional permutation of indexes.

Hi Andrey,

why is the hash table common and not instanciated multiple times for 
each namespace like the routes ?

