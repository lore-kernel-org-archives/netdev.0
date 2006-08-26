From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Fri, 25 Aug 2006 21:16:15 -0700
Message-ID: <44EFCB0F.5080506@zytor.com>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com> <44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net> <44ED2797.4070304@zytor.com> <20060824125046.GA25439@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gay <andy@andynet.net>, David Miller <davem@davemloft.net>,
	tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:20148 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S932337AbWHZERR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 00:17:17 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060824125046.GA25439@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov wrote:
> Hello!
> 
>> I'm thinking that David definitely has a point about having a usability 
>> problem, though.  All other kind of tunnels have endpoint devices 
>> associated with them, and that would make all these kinds of problems go 
>> away, 
> 
> Yes, when you deal with sane practical setups, this approach is the only
> reasonable one.
> 
> Unfortunately, IPsec is not something totally sane and practical :-),
> "security gateway" case is small part of it and "routing" viewpoint
> clashes fatally with another requirements. Pure result is that we use approach
> where it is possible to do everything with some efforts, rather than approach
> which is simple and intuitive, but does not allow to do many things.
> 

Fair enough.  However, that does beg a question: is there any sane way 
to create the pseudo-device model on top of the current model, as a 
convenience layer?  That way you could get the best of both.

	-hpa
