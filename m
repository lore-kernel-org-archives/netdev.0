From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
Date: Thu, 19 May 2016 05:41:55 +0000
Message-ID: <BLUPR03MB141050990AB0D651168EA8EFBF4A0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <20160515.131606.1794366975297405715.davem@davemloft.net>
	<BLUPR03MB141097E05C16CB619E942AA2BF480@BLUPR03MB1410.namprd03.prod.outlook.com>
	<BLUPR03MB1410BB9D04D0758840F6685CBF4A0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160518.211242.1326033872866679163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"apw@canonical.com" <apw@canonical.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0145.outbound.protection.outlook.com ([207.46.100.145]:7239
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750790AbcESFmA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 01:42:00 -0400
In-Reply-To: <20160518.211242.1326033872866679163.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 19, 2016 12:13
> To: Dexuan Cui <decui@microsoft.com>
> Cc: KY Srinivasan <kys@microsoft.com>; olaf@aepfle.de;
> gregkh@linuxfoundation.org; jasowang@redhat.com; linux-
> kernel@vger.kernel.org; joe@perches.com; netdev@vger.kernel.org;
> apw@canonical.com; devel@linuxdriverproject.org; Haiyang Zhang
> <haiyangz@microsoft.com>
> Subject: Re: [PATCH v11 net-next 0/1] introduce Hyper-V VM Sockets(hv_sock)
> 
> 
> I'm travelling and very busy with the merge window.  So sorry I won't be able
> to think about this for some time.

David, 
Sure, I understand.

Please let me recap my last mail:

1)  I'll replace my statically-allocated per-connection "send/recv bufs" with
dynamically ones, so no buf is used when there is no traffic.

2) Another kind of bufs i.e., the  multi-page "VMBus send/recv ringbuffer", is
a must IMO due to the host side's design of the feature: every connection needs
its own ringbuffer, which takes several pages (2~3 pages at least. And, 5 pages
should suffice for good performance). The ringbuffer can be accessed by the
host at any time, so IMO the pages can't be swappable.

I understand net-next is closed now. I'm going to post the next version
after 4.7-rc1 is out in several weeks.

If you could give me some suggestions, I would be definitely happy to take.

Thanks!
-- Dexuan
