From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH] bna: bnad_udelay macro cleanup
Date: Thu, 23 Dec 2010 10:00:32 -0800
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A5CFD83694@HQ1-EXCH01.corp.brocade.com>
References: <1293087949-17613-1-git-send-email-rmody@brocade.com>
 <20101223.093819.104073648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Debashis Dutt <ddutt@Brocade.COM>,
	Jing Huang <huangj@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:58797 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752649Ab0LWSAx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:00:53 -0500
In-Reply-To: <20101223.093819.104073648.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, December 23, 2010 9:38 AM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Wed, 22 Dec 2010 23:05:49 -0800
>
>> Change details:
>> 	- Removed unnecessary bnad_udelay macro for ia64
>>
>> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
>> Signed-off-by: Rasesh Mody <rmody@brocade.com>
>
>Please don't do it this way.
>
>We don't add known crap, then add a patch to remove the crap.
>
>Respin your BNA patch series so that this IA64 stuff never shows
>up in the first place.
>
>Thanks.

We'll respin and resubmit the patches with ia64 macro removed as
per your suggestion. In future we'll take care to avoid this.

--Rasesh
