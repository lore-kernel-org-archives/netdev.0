From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: ProxyARP and IPSec
Date: Sat, 02 Sep 2006 10:30:42 -0700
Message-ID: <44F9BFC2.4050001@zytor.com>
References: <44EBA1FC.5000801@zytor.com>	<20060823191425.GK3470@postel.suug.ch>	<20060823.151424.78711856.davem@davemloft.net>	<20060823231812.GA32394@ms2.inr.ac.ru>	<44ECFCF1.10500@zytor.com>	<44ECFD5F.6060901@zytor.com>	<1156386043.7302.773.camel@tahini.andynet.net>	<44ED2797.4070304@zytor.com>	<20060824125046.GA25439@ms2.inr.ac.ru>	<44EFCB0F.5080506@zytor.com> <17657.42254.455342.157858@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:10369 "EHLO
	terminus.zytor.com") by vger.kernel.org with ESMTP id S1751225AbWIBRat
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 13:30:49 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <17657.42254.455342.157858@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen J. Bevan wrote:
> H. Peter Anvin writes:
>  > Fair enough.  However, that does beg a question: is there any sane way 
>  > to create the pseudo-device model on top of the current model, as a 
>  > convenience layer?  That way you could get the best of both.
> 
> I assume you were using tunnel-mode IPsec and depending on exactly
> what you want to do you may be able to replace it with transport mode
> IPsec (or stay with tunnel if the extra 20 bytes of IP is not a
> problem) to handle host<->host IPsec and use gre or ipip for overlay
> network.  That way you get a virtual device (gre or ipip) you can
> route to, run OSPF on, ... etc.

<sarcasm>

What I great idea.  Now I just have to get every host I want to 
interoperate with to support a nonstandard configuration.  The scary 
part is that if I motivate it with "Linux is too stupid to handle 
standard tunnel-mode IPsec" I might actually get away with it.

</sarcasm>

Really... if saying our configuration is so screwed up that we have to 
run a different over-wire protocol isn't an admission of failure I don't 
know what is.  I suspect this contributes to the growth in OpenVPN as well.

	-hpa

-- 
VGER BF report: U 0.500003
