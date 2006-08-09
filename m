From: David Miller <davem@davemloft.net>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 09 Aug 2006 00:00:21 -0700 (PDT)
Message-ID: <20060809.000021.71089437.davem@davemloft.net>
References: <20060808.233156.74748104.davem@davemloft.net>
	<20060809064923.GB7154@2ka.mipt.ru>
	<44D9874E.4020402@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3481
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964905AbWHIHAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:00:19 -0400
To: drepper@redhat.com
In-Reply-To: <44D9874E.4020402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 08 Aug 2006 23:57:18 -0700

> For exec (where a file descriptor might survive) we likely need a
> mechanism to mmap the ring buffer only based on the file descriptor.
> I'm not sure about this, though.

Unless we can come up with a serious legitimate use for this, I think
we can forego it for now.

