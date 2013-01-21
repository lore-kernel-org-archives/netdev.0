From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 20:50:13 +0900
Message-ID: <50FD2B75.5040705@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com> <50FCA825.7070609@linux-ipv6.org> <50FCDF5D.3060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49999 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752964Ab3AULuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 06:50:15 -0500
In-Reply-To: <50FCDF5D.3060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:

>> And, firewire driver does not seem to support zerocopy
>> (fragmented skb) support.  It help performance.
> 
> O.k., good point. I will have a look into that. But I suggest to not mix up this issue with the IPv6 over firewire enhancement. That should be a separate patch.

I agree, but do we have to two fifos? for what?
If it is for performance, zerocopy should help.

--yoshfuji
