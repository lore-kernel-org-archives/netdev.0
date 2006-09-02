From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: ProxyARP and IPSec
Date: Sat, 2 Sep 2006 08:36:46 -0700
Message-ID: <17657.42254.455342.157858@localhost.localdomain>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:54776 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1750840AbWIBPhZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 11:37:25 -0400
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <44EFCB0F.5080506@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

H. Peter Anvin writes:
 > Fair enough.  However, that does beg a question: is there any sane way 
 > to create the pseudo-device model on top of the current model, as a 
 > convenience layer?  That way you could get the best of both.

I assume you were using tunnel-mode IPsec and depending on exactly
what you want to do you may be able to replace it with transport mode
IPsec (or stay with tunnel if the extra 20 bytes of IP is not a
problem) to handle host<->host IPsec and use gre or ipip for overlay
network.  That way you get a virtual device (gre or ipip) you can
route to, run OSPF on, ... etc.

-- 
VGER BF report: U 0.498333
