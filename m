From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 4/9] network namespaces: socket hashes
Date: Thu, 21 Sep 2006 14:34:53 +0200
Message-ID: <451286ED.4070500@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060815184844.A2882@castle.nmd.msu.ru> <450EB771.9080609@fr.ibm.com> <20060920203222.B10791@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:45372 "EHLO
	mtagate6.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751099AbWIUMfF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 08:35:05 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8LCZ3gQ036050
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 12:35:03 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8LCbH5v1904650
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 13:37:18 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8LCZ1A5018707
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 13:35:02 +0100
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060920203222.B10791@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:

> The main reason is that socket hash tables should be large enough to work
> efficiently, but it isn't good to waste a lot of memory for each namespace.
> Namespaces should be cheap enough, to allow to have hundreds of them.
> This reason of memory efficiency, of course, has a priority unless/until
> socket hash tables start to resize automatically.
> 
> Another point is that routing lookup is much more complicated than the
> socket's one to add another search key.
> Routing also have additional routines for deleting entries matching some
> patterns, and so on.
> In short, routing is much more complicated, and it already quite efficient
> for various sizes of routing tables.

That makes sense, thx for the explanation.

Cheers.
	-- Daniel.


