From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Mon, 04 Sep 2006 22:17:38 -0700
Message-ID: <44FD0872.80104@zytor.com>
References: <44EBA1FC.5000801@zytor.com>	<20060823191425.GK3470@postel.suug.ch>	<20060823.151424.78711856.davem@davemloft.net>	<20060823231812.GA32394@ms2.inr.ac.ru>	<44ECFCF1.10500@zytor.com>	<44ECFD5F.6060901@zytor.com>	<1156386043.7302.773.camel@tahini.andynet.net>	<44ED2797.4070304@zytor.com>	<20060824125046.GA25439@ms2.inr.ac.ru>	<44EFCB0F.5080506@zytor.com>	<17657.42254.455342.157858@localhost.localdomain>	<44F9BFC2.4050001@zytor.com> <17657.61339.125326.706889@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:11490 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S965158AbWIEFRo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 01:17:44 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <17657.61339.125326.706889@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen J. Bevan wrote:

> 
>  > Really... if saying our configuration is so screwed up that we have to 
>  > run a different over-wire protocol isn't an admission of failure I don't 
> 
> If you use ipip the over-wire protocol is identical, see RFC 3884
> section 3.1 or you can test it right now using manual keying (remote
> side uses tunnel mode, your side uses transport + ipip).  To use IKE
> pluto would need to be hacked a bit, though most of the changes could
> be handled via a updown script.
> 

Interesting.  It might be interesting to implement userspace (e.g. 
OpenSwan) in such a way that all tunnel-mode IPsec is implemented this 
way automatically, using an ipip interface in the kernel.

	-hpa

