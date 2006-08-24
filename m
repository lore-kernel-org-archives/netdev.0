From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Wed, 23 Aug 2006 18:14:07 -0700
Message-ID: <44ECFD5F.6060901@zytor.com>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:12227 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S1030183AbWHXBOo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 21:14:44 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <44ECFCF1.10500@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H. Peter Anvin wrote:
> Alexey Kuznetsov wrote:
>>
>> The question is where is this host really?
>>
>> If it is far far away and connected only via IPsec tunnel with 
>> destionation
>> of tunnel different of host address
>>
>> ip ro add THEHOST dev dummy0
>>
>> should be enough. It asserts that THEHOST is not on eth0.
>> IPsec policy will figure out correct route, unless something is broken.
>>
> 
> Just tried it, and it works as advertised.
> 

... except that OpenSwan will rip out the route and install a route 
pointing to eth0, thus breaking the thing again.

	-hpa

