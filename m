From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 19:10:56 -0400
Message-ID: <46313180.6040809@redhat.com>
References: <46311F76.9040803@redhat.com> <20070426.150434.91313967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755184AbXDZXLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 19:11:05 -0400
In-Reply-To: <20070426.150434.91313967.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Chuck Ebbert <cebbert@redhat.com>
> Date: Thu, 26 Apr 2007 17:53:58 -0400
> 
>> And what does this do?
>>
>> +	switch (hdr->type) {
>> +#ifdef CONFIG_IPV6_MIP6
>> +		break;
>> +#endif
>>
>> break by itself like that doesn't do anything. If it did
>> then people with mobile ipv6 enabled would always accept all
>> source routing. (They should at least know that's a problem.)
> 
> We are aware of this part already, and I've sent the fix to
> the -stable folks and Linus so we can figure out how to deal
> with this and the netlink OOPS'er too.
> 

Another question: is it a good idea to even be shipping release
kernels with Mobile IPV6 enabled? Unfortunately, "experimental"
isn't enough to go by...

