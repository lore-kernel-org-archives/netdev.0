From: Patrick McHardy <kaber@trash.net>
Subject: Re: nft 0.4, crash on list
Date: Sun, 22 Mar 2015 05:33:13 +0000
Message-ID: <20150322053313.GA16931@acer.localdomain>
References: <fded527361344541342afa2478b5ca9a@visp.net.lb>
 <74645ce188ee403b5ffcf2303046f694@visp.net.lb>
 <a457f2eac526c6fe6e6f80634358d587@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Pablo <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50899 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbCVFdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 01:33:24 -0400
Content-Disposition: inline
In-Reply-To: <a457f2eac526c6fe6e6f80634358d587@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.03, Denys Fedoryshchenko wrote:
> Sorry for noise, seems git version working fine!

Still this shouldn't be happening. Just to confirm, you were using an
unpatched kernel and by git you mean nftables git?


> On 2015-03-22 00:49, Denys Fedoryshchenko wrote:
> >Additionally, if i will do "nft flush table mangle" , with this table
> >added i will get this:
> >[   42.800078] ------------[ cut here ]------------
> >[   42.800092] WARNING: CPU: 3 PID: 2868 at
> >net/netfilter/nf_tables_api.c:4122 nft_data_uninit+0x35/0x50
> >[nf_tables]()
