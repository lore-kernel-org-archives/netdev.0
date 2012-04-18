From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH 2/2] l2tp: Introduce L2TPv3 IP encapsulation support
 for IPv6
Date: Wed, 18 Apr 2012 14:56:39 +0100
Message-ID: <4F8EC817.1040109@katalix.com>
References: <y> <1334665766-11461-3-git-send-email-jchapman@katalix.com> <20120418.002820.1941255513481211357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52654 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874Ab2DRN4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 09:56:45 -0400
In-Reply-To: <20120418.002820.1941255513481211357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/04/12 05:28, David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Tue, 17 Apr 2012 13:29:26 +0100
> 
>> L2TPv3 defines an IP encapsulation packet format where data is carried
>> directly over IP (no UDP). The kernel already has support for L2TP IP
>> encapsulation over IPv4 (l2tp_ip). This patch introduces support for L2TP
>> IP encapsulation over IPv6.
> 
> Either the ipv4 side should be changed to use ip4_datagram_connect()
> or the ipv6 side should duplicate just the parts of
> ip6_datagram_connect() it needs.
> 
> Which is it? :-)

Ok, I'll add a patch to l2tp_ip to have it use ip4_datagram_connect(). :-)
