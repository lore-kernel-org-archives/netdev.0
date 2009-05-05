From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: introduce a list of device addresses
	dev_addr_list (v5)
Date: Tue, 5 May 2009 08:37:16 +0200
Message-ID: <20090505063715.GA3375@psychotron.englab.brq.redhat.com>
References: <20090417115723.GE9556@psychotron.englab.brq.redhat.com> <20090418085848.GC3370@psychotron.englab.brq.redhat.com> <20090504111417.GE3402@psychotron.englab.brq.redhat.com> <20090504.213730.131875923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51266 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZEEGkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 02:40:43 -0400
Content-Disposition: inline
In-Reply-To: <20090504.213730.131875923.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 05, 2009 at 06:37:30AM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Mon, 4 May 2009 13:14:18 +0200
>
>> +static void __hw_addr_del_multiple(struct list_head *to_list,
>> +				   struct list_head *from_list,
>> +				   int addr_len, unsigned char addr_type)
>> +{
>> +	__hw_addr_del_multiple_ii(to_list, from_list, addr_len, addr_type, -1);
>> +}
>
>Unused static function, this will create build warnings.
>
>Or, it should :-)

I'm aware.
>
>If you plan to use such a function in subsequent patches, add
>it in those changes not here.

Yes, Ok, I was not quite sure. Thanks for explanation, I'll resubmit later
today.
>
>Otherwise I have no fundamental objection to this patch, nice
>work!
