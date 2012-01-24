From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [net PATCH 1/1] qlge:Changing netdev msg level to default debug
Date: Tue, 24 Jan 2012 13:42:55 -0800
Message-ID: <5E4F49720D0BAD499EE1F01232234BA874379FBFD7@AVEXMB1.qlogic.org>
References: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <20120124.153837.905415925299369179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:11559 "EHLO
	TX2EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab2AXVnD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:43:03 -0500
In-Reply-To: <20120124.153837.905415925299369179.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Ok, will do as suggested. 

Jiten

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, January 24, 2012 12:39 PM
To: Jitendra Kalsaria
Cc: netdev; Ron Mercer; Dept-NX Linux NIC Driver
Subject: Re: [net PATCH 1/1] qlge:Changing netdev msg level to default debug

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Mon, 23 Jan 2012 15:38:52 -0800

> Driver was passing -1 so that custom default get used but which
> makes it even more sane than 15 which was excessively verbose
> printing an unusual amount of messages.
> 
> Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Please don't move this code away from the canonical way in which
default message levels are handled.

The canonical way is to specify a module param that starts with the
value "-1" which when passed as the first argument to netif_msg_init()
means "use the default mask" which is the second argument.

Moving to a default of "3" makes no sense at all, express the default
in the second argument of netif_msg_init(), not the first.

I'm not applying this patch, use other drivers such as tg3.c as a
guide.
