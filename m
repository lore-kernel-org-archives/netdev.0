From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: nft 0.4, crash on list
Date: Sun, 22 Mar 2015 10:05:10 +0200
Message-ID: <d029673de6d7994d231a4a37df763951@visp.net.lb>
References: <fded527361344541342afa2478b5ca9a@visp.net.lb>
 <74645ce188ee403b5ffcf2303046f694@visp.net.lb>
 <a457f2eac526c6fe6e6f80634358d587@visp.net.lb>
 <20150322053313.GA16931@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Pablo <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:43206 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbbCVIFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:05:14 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 3207948022D
	for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:05:11 +0200 (EET)
In-Reply-To: <20150322053313.GA16931@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-03-22 07:33, Patrick McHardy wrote:
> On 22.03, Denys Fedoryshchenko wrote:
>> Sorry for noise, seems git version working fine!
> 
> Still this shouldn't be happening. Just to confirm, you were using an
> unpatched kernel and by git you mean nftables git?
Yes, correct. I tested on 3.18.8 and 3.19.2 vanilla kernels (x86_64).
On nftables 0.4 it does crash, on nftables git it doesn't.

> 
> 
>> On 2015-03-22 00:49, Denys Fedoryshchenko wrote:
>> >Additionally, if i will do "nft flush table mangle" , with this table
>> >added i will get this:
>> >[   42.800078] ------------[ cut here ]------------
>> >[   42.800092] WARNING: CPU: 3 PID: 2868 at
>> >net/netfilter/nf_tables_api.c:4122 nft_data_uninit+0x35/0x50
>> >[nf_tables]()
