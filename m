From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 18:12:17 -0700
Message-ID: <44ECFCF1.10500@zytor.com>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:37063 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S965320AbWHXBNL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:13:11 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060823231812.GA32394@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> 
> The question is where is this host really?
> 
> If it is far far away and connected only via IPsec tunnel with destionation
> of tunnel different of host address
> 
> ip ro add THEHOST dev dummy0
> 
> should be enough. It asserts that THEHOST is not on eth0.
> IPsec policy will figure out correct route, unless something is broken.
> 

Just tried it, and it works as advertised.

	-hpa
