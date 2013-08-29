From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 0/3] pf_packet updates
Date: Thu, 29 Aug 2013 08:20:14 +0200
Message-ID: <521EE81E.7030800@redhat.com>
References: <1377720791-15844-1-git-send-email-dborkman@redhat.com> <20130829.013938.2144325735677512661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Cong Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab3H2GUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 02:20:20 -0400
In-Reply-To: <20130829.013938.2144325735677512661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2013 07:39 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 28 Aug 2013 22:13:08 +0200
>
>> Daniel Borkmann (3):
>>    net: packet: add random fanout scheduler
>>    net: packet: use reciprocal_divide in fanout_demux_hash
>>    net: packet: document available fanout policies
>
> Please add the missing reciprocal_divide.h include to the second
> patch, as per Eric Dumazet's feedback, and resubmit this series.

That is already the case in the first patch of the series. It adds:

...
+#include <linux/reciprocal_div.h>
...
