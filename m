From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next 0/3] pf_packet updates
Date: Thu, 29 Aug 2013 16:43:54 -0400 (EDT)
Message-ID: <20130829.164354.1224543843394684970.davem@redhat.com>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
	<20130829.013938.2144325735677512661.davem@davemloft.net>
	<521EE81E.7030800@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757059Ab3H2Un4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 16:43:56 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7TKht19023121
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 16:43:55 -0400
In-Reply-To: <521EE81E.7030800@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 29 Aug 2013 08:20:14 +0200

> On 08/29/2013 07:39 AM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 28 Aug 2013 22:13:08 +0200
>>
>>> Daniel Borkmann (3):
>>>    net: packet: add random fanout scheduler
>>>    net: packet: use reciprocal_divide in fanout_demux_hash
>>>    net: packet: document available fanout policies
>>
>> Please add the missing reciprocal_divide.h include to the second
>> patch, as per Eric Dumazet's feedback, and resubmit this series.
> 
> That is already the case in the first patch of the series. It adds:
> 
> ...
> +#include <linux/reciprocal_div.h>

Series applied, thanks Daniel.
