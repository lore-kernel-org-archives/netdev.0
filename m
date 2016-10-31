From: David Miller <davem@davemloft.net>
Subject: Re: mv643xx_eth.c merge gone bad...
Date: Mon, 31 Oct 2016 10:34:03 -0400 (EDT)
Message-ID: <20161031.103403.293968855937308643.davem@davemloft.net>
References: <20161031113349.GA8951@lunn.ch>
        <20161031.091206.236633139585216348.davem@davemloft.net>
        <20161031133538.GB9441@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe@obsidianresearch.com, jarod@redhat.com,
        netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942957AbcJaOeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 10:34:07 -0400
In-Reply-To: <20161031133538.GB9441@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 31 Oct 2016 14:35:38 +0100

> On Mon, Oct 31, 2016 at 09:12:06AM -0400, David Miller wrote:
>> From: Andrew Lunn <andrew@lunn.ch>
>> Date: Mon, 31 Oct 2016 12:33:49 +0100
>> 
>> > The merge of commit 27058af401e49d88a905df000dd26f443fcfa8ce for
>> > mv643xx_eth.c has gone bad:
>> 
>> Sorry this should be fixed now.
> 
> Hi David
> 
> I think the SET_NETDEV_DEV() should be removed, which is what cause the merged conflict:
> 
> http://patchwork.ozlabs.org/patch/687294/

Indeed, fixed.

Thanks Andrew.
