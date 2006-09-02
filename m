From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: ProxyARP and IPSec
Date: Sat, 2 Sep 2006 13:54:51 -0700
Message-ID: <17657.61339.125326.706889@localhost.localdomain>
References: <44EBA1FC.5000801@zytor.com>
	<20060823191425.GK3470@postel.suug.ch>
	<20060823.151424.78711856.davem@davemloft.net>
	<20060823231812.GA32394@ms2.inr.ac.ru>
	<44ECFCF1.10500@zytor.com>
	<44ECFD5F.6060901@zytor.com>
	<1156386043.7302.773.camel@tahini.andynet.net>
	<44ED2797.4070304@zytor.com>
	<20060824125046.GA25439@ms2.inr.ac.ru>
	<44EFCB0F.5080506@zytor.com>
	<17657.42254.455342.157858@localhost.localdomain>
	<44F9BFC2.4050001@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Stephen J. Bevan" <stephen@dino.dnsalias.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:61694 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1751577AbWIBUza
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 16:55:30 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <44F9BFC2.4050001@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > <sarcasm>
 > 
 > What I great idea.  Now I just have to get every host I want to 
 > interoperate with to support a nonstandard configuration.  The scary 
 > part is that if I motivate it with "Linux is too stupid to handle 
 > standard tunnel-mode IPsec" I might actually get away with it.
 > 
 > </sarcasm>

Linux handles tunnel-mode IPsec in the same way that most IPsec
vendors did and many still do.  For example, Cisco IOS has pages and
pages of documentation about how to combine IPsec with GRE in order to
support securely running OSPF between sites, precisely because its
IPsec didn't offer a virtual interface.  However, Cisco (along with
Netscreen/Juniper and Fortinet) now additionally support IPsec that
uses a virtual interface and so you have a choice of using an
interface or not as you see fit.  I would be useful if Linux offered
the option but code talks and I'm not offering a patch so I'm not in a
position to complain about what Linux currently supports.


 > Really... if saying our configuration is so screwed up that we have to 
 > run a different over-wire protocol isn't an admission of failure I don't 

If you use ipip the over-wire protocol is identical, see RFC 3884
section 3.1 or you can test it right now using manual keying (remote
side uses tunnel mode, your side uses transport + ipip).  To use IKE
pluto would need to be hacked a bit, though most of the changes could
be handled via a updown script.


 > know what is.  I suspect this contributes to the growth in OpenVPN as well.

Haven't you heard, SSL based VPNs are the future :-)

-- 
VGER BF report: U 0.947229
