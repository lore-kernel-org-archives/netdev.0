From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC:] struct net_device_ops: Add function pointer to fill device
 specific ndisc information
Date: Mon, 21 Jan 2013 11:29:57 +0900
Message-ID: <50FCA825.7070609@linux-ipv6.org>
References: <50FC2EE4.3080705@gmail.com> <50FC3BB1.4070005@linux-ipv6.org> <50FC6068.3020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux1394-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49423 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752568Ab3AUC37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 21:29:59 -0500
In-Reply-To: <50FC6068.3020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
> On 01/20/2013 07:47 PM, YOSHIFUJI Hideaki wrote:
> 
>> My current position is to change "mac address" to
>>
>> struct fwnet_hwaddr {
>>     u8    guid[8];
>>     u8    max_rec;
>>     u8    sspd;
>>     u8    fifo[6];
>> };
>>
> 
> That is something I'm not really convinced of. As Stefan Richter pointed out clearly, the fifo address might be different between IPv4 and IPv6 communication.

We could have multiple "net_device"s per single physical
interface at the same time, then.

Multicast is a big issue.  Because IPv6 is fan of
multicast, and it uses link-local multicast as its
core infrastructure.  Without infrastructure to
support it, I'm not going to agree.

And, firewire driver does not seem to support zerocopy
(fragmented skb) support.  It help performance.

--yoshfuji
