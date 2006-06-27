From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 27 Jun 2006 08:45:52 +0200
Message-ID: <BAY103-F48CEDE1C901D0DF661A82B27E0@phx.gbl>
References: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f4.bay103.hotmail.com ([65.54.174.14]:63408 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S932261AbWF0Gp5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 02:45:57 -0400
In-Reply-To: <BAY103-F5BDFFFFDAB4CFB03007D9B2A60@phx.gbl>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>>Herbert Xu wrote:
>>
>>>However, the fact that the tcpdump causes more chunky packets to
>>>make it through could be an indication that there is a bug somewhere
>>>in our NAT/IPsec code or at least a suboptimal memory allocation
>>>strategy that's somehow avoided when AF_PACKET pins the skb down.

JFYI: same problem with 2.6.17-git10 (tcpdump 'resolves' the
problem)


