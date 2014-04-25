From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2 2/5] net: filter: misc/various cleanups
Date: Fri, 25 Apr 2014 09:52:14 +0200
Message-ID: <535A142E.9060609@redhat.com>
References: <1398321927-8845-1-git-send-email-dborkman@redhat.com> <1398321927-8845-3-git-send-email-dborkman@redhat.com> <20140424.160050.2258325688773881218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbaDYHwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 03:52:25 -0400
In-Reply-To: <20140424.160050.2258325688773881218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/24/2014 10:00 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Thu, 24 Apr 2014 08:45:24 +0200
>
>> +	return __skb_get_poff((struct sk_buff *)(long) ctx);
>
> Please use "unsigned long" when casting pointers to/from integers.

I'll fix it up, thanks.

There's ongoing work to improve the documentation file to address
your concerns.

Thanks,

Daniel
