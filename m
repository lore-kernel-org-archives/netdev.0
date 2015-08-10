From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [RFC PATCH] net: ipv4: increase dhcp inter device timeout
Date: Mon, 10 Aug 2015 10:30:24 +0530
Message-ID: <55C82FE8.6020800@ti.com>
References: <1438928970-23908-1-git-send-email-mugunthanvnm@ti.com> <55C45B22.1090909@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:41120 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbbHJFBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 01:01:15 -0400
In-Reply-To: <55C45B22.1090909@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 August 2015 12:45 PM, YOSHIFUJI Hideaki wrote:
>> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
>> > index 8e7328c..bdb8cb5 100644
>> > --- a/net/ipv4/ipconfig.c
>> > +++ b/net/ipv4/ipconfig.c
>> > @@ -94,7 +94,7 @@
>> >  /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
>> >  #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
>> >  #define CONF_SEND_RETRIES 	6	/* Send six requests per open */
>> > -#define CONF_INTER_TIMEOUT	(HZ/2)	/* Inter-device timeout: 1/2 second */
>> > +#define CONF_INTER_TIMEOUT	(HZ)	/* Inter-device timeout: 1/2 second */
> You should update comment as well at least.

Will update in next version.

Regards
Mugunthan V N
