From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Tue, 5 Aug 2008 05:46:04 +0100
Message-ID: <20080805044604.GA28946@ZenIV.linux.org.uk>
References: <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl> <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl> <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk> <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl> <20080804215649.GZ28946@ZenIV.linux.org.uk> <Pine.LNX.4.64.0808050000360.29400@bizon.gios.gov.pl> <Pine.LNX.4.64.0808050301400.29400@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:36394 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbYHEEqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 00:46:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0808050301400.29400@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 03:08:17AM +0200, Krzysztof Oledzki wrote:
> issue seems to be now solved. However, starting from the
> 9043476f726802f4b00c96d0c4f418dde48d1304, even with NETFILNER=n, there are 
> other duplicated entries:
>
> # find /proc/sys -type d |sort|uniq -d
>
> /proc/sys/net/core
> /proc/sys/net/ipv4/route
> /proc/sys/net/ipv6

... dealt with by eeb61f719c00c626115852bbc91189dc3011a844.  Or are you
seeing those again?
