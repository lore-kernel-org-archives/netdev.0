From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 31 Jan 2012 08:56:12 -0800
Message-ID: <20120131085612.3bb50a51@nehalam.linuxnetplumber.net>
References: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
	<4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stefan Gula <steweg@ynet.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36992 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479Ab2AaQ4P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jan 2012 11:56:15 -0500
In-Reply-To: <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Jan 2012 14:21:51 +0100 (CET)
Stefan Gula <steweg@ynet.sk> wrote:

> From: Stefan Gula <steweg@gmail.com>
> 
> This patch is an extension for current Ethernet over GRE
> implementation, which allows user to create virtual bridge (multipoint
> VPN) and forward traffic based on Ethernet MAC address information in
> it. It simulates the Bridge behavior learning mechanism, but instead
> of learning port ID from which given MAC address comes, it learns IP
> address of peer which encapsulated given packet. Multicast, Broadcast
> and unknown-multicast traffic is send over network as multicast
> encapsulated GRE packet, so one Ethernet multipoint GRE tunnel can be
> represented as one single virtual switch on logical level and be also
> represented as one multicast IPv4 address on network level.
> 
> Signed-off-by: Stefan Gula <steweg@gmail.com>

Have you looked at the NVGRE standard? 
  http://tools.ietf.org/html/draft-sridharan-virtualization-nvgre-00
