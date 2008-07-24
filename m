From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.26: [<c0133cc1>] __alloc_pages_internal+0x331/0x343
Date: Thu, 24 Jul 2008 17:06:30 +0200
Message-ID: <BAY103-DAV74E605DFBE7CC22EEA732B2870@phx.gbl>
References: <BAY103-DAV1DBA31C9BCB4C6FFB3DE0B2870@phx.gbl> <20080723.234556.98132946.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758091AbYGXPJW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> > Jul 23 12:40:03 Electra kernel:  [<c024d2a5>]
> > pskb_expand_head+0x41/0x164
> > Jul 23 12:40:03 Electra kernel:  [<c029a6b4>]
> > ipcomp_decompress+0x60/0xa1
>
> ipcomp_decompress() should probably be changed to try and build
> a scatterlist of pages for the resulting packet SKB data instead
> of building a linear buffer as it does now.

Thanks for the reply.
I got a similar error today also with 2.6.25.10
after 20 days uptime.
This box is running 2.6.25 since april 22: I have
never seen these errors.
