From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] netlink, mmap: transform mmap skb into full skb on
 taps
Date: Sat, 12 Sep 2015 00:18:54 +0200
Message-ID: <55F3534E.4050405@iogearbox.net>
References: <55F2AC29.3030209@iogearbox.net>	<20150911.124205.1992250802389107845.davem@davemloft.net>	<55F33AFC.1080206@iogearbox.net> <20150911.143459.1484553569083753621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chamaken@gmail.com, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50362 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbbIKWS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 18:18:58 -0400
In-Reply-To: <20150911.143459.1484553569083753621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2015 11:34 PM, David Miller wrote:
...
> Another approach would be to put the mmap user data into a page frag,
> but that obviously has some costs associated with it.  However,
> nothing in netlink is ready for fragged skbs yet.  It's the reason why
> we have the large skb via vmalloc facility.
>
> Long term fixing that is probably the way to go, but that would be an
> enormous project.

Yeah, that could resolve it.
