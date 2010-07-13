From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next-2.6]  macvtap: Return error when macvlan drops
 the packet
Date: Tue, 13 Jul 2010 09:42:24 -0700
Message-ID: <1279039344.7719.19.camel@localhost.localdomain>
References: <1278924474.7719.14.camel@localhost.localdomain>
	 <201007121244.04499.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org, davem@davemloft.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:53857 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366Ab0GMQmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 12:42:35 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6DGYFXs016452
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 10:34:15 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6DGgSh2159748
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 10:42:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6DGgP5G021142
	for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 10:42:27 -0600
In-Reply-To: <201007121244.04499.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Arnd,

I am working on macvtap zero-copy patch. I found that the packet was
silently dropped and packet out of order when using zero-copy. That was
a reason I submitted this patch to switch to copy mode when that
happens. I think I might need more time to debug why first.

Thanks
Shirley

