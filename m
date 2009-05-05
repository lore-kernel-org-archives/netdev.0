From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce a list of device addresses
 dev_addr_list (v5)
Date: Mon, 04 May 2009 21:37:30 -0700 (PDT)
Message-ID: <20090504.213730.131875923.davem@davemloft.net>
References: <20090417115723.GE9556@psychotron.englab.brq.redhat.com>
	<20090418085848.GC3370@psychotron.englab.brq.redhat.com>
	<20090504111417.GE3402@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51243
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbZEEEhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 00:37:35 -0400
In-Reply-To: <20090504111417.GE3402@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 4 May 2009 13:14:18 +0200

> +static void __hw_addr_del_multiple(struct list_head *to_list,
> +				   struct list_head *from_list,
> +				   int addr_len, unsigned char addr_type)
> +{
> +	__hw_addr_del_multiple_ii(to_list, from_list, addr_len, addr_type, -1);
> +}

Unused static function, this will create build warnings.

Or, it should :-)

If you plan to use such a function in subsequent patches, add
it in those changes not here.

Otherwise I have no fundamental objection to this patch, nice
work!
