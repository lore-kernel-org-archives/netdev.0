From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Mon, 4 Aug 2008 21:00:58 +0100
Message-ID: <20080804200058.GX28946@ZenIV.linux.org.uk>
References: <20080803143730.7747e9a8@infradead.org> <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49389 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000AbYHDUBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 16:01:03 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 09:41:10PM +0200, Krzysztof Oledzki wrote:

>> BTW: It also happens when I revert my patch:
>>
>> sysctl -a|grep net.netfilter
>>
>> net.netfilter.nf_conntrack_generic_timeout = 600
>> net.netfilter.nf_conntrack_generic_timeout = 600
>
> And the winner is... 9043476f726802f4b00c96d0c4f418dde48d1304:
>
> [PATCH] sanitize proc_sysctl

Almost definitely problems with registration order ;-/  I'll look into
that once I get a bit of sleep...
