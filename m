From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: ProxyARP and IPSec
Date: Thu, 24 Aug 2006 16:50:46 +0400
Message-ID: <20060824125046.GA25439@ms2.inr.ac.ru>
References: <44EBA1FC.5000801@zytor.com> <20060823191425.GK3470@postel.suug.ch> <20060823.151424.78711856.davem@davemloft.net> <20060823231812.GA32394@ms2.inr.ac.ru> <44ECFCF1.10500@zytor.com> <44ECFD5F.6060901@zytor.com> <1156386043.7302.773.camel@tahini.andynet.net> <44ED2797.4070304@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gay <andy@andynet.net>, David Miller <davem@davemloft.net>,
	tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:28123 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751220AbWHXMvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 08:51:48 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
Content-Disposition: inline
In-Reply-To: <44ED2797.4070304@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I'm thinking that David definitely has a point about having a usability 
> problem, though.  All other kind of tunnels have endpoint devices 
> associated with them, and that would make all these kinds of problems go 
> away, 

Yes, when you deal with sane practical setups, this approach is the only
reasonable one.

Unfortunately, IPsec is not something totally sane and practical :-),
"security gateway" case is small part of it and "routing" viewpoint
clashes fatally with another requirements. Pure result is that we use approach
where it is possible to do everything with some efforts, rather than approach
which is simple and intuitive, but does not allow to do many things.

It is possible to simulate simple life, creating "ipsecX" devices
with disabled xfrm and route all the tunnels there. That would be handy.

I would just advice to rename one of dummy devices to "ipsec0"
and route all the IPsec tunnels there. It is also simple.

What's about iptables, I am sorry, it is too flexible to control IPsec. :-)
One day, someone with enough of energy and stamina will make flow cache
to unify all the kinds of policy rules. Until that day, you have to tune
all three policy sets (routing, ipsec and iptables) separately and take
care of the cases, when one set has to cheat another. :-)

Alexey
