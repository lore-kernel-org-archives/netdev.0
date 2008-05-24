From: James Chapman <jchapman@katalix.com>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 11:37:38 +0100
Message-ID: <4837EFF2.40807@katalix.com>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>	 <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com>	 <1211569604.11907.37.camel@perihelion>	 <20080523225435.GT20815@postel.suug.ch>	 <1211603155.11907.79.camel@perihelion>	 <alpine.LNX.1.10.0805240646380.19084@fbirervta.pbzchgretzou.qr>	 <20080524051630.GD20890@auslistsprd01.us.dell.com>	 <4837DCA4.5070806@katalix.com> <1211621632.31212.73.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jon Masters <jonathan@jonmasters.org>,
	Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:44750 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754301AbYEXKh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 May 2008 06:37:58 -0400
In-Reply-To: <1211621632.31212.73.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Sat, 2008-05-24 at 10:15 +0100, James Chapman wrote:
>> Wouldn't it be better to fix any applications that can't handle
>> renamed devices?
> 
> _Are_ there any such applications? Other than NetworkManager crapping
> itself when the device name is too long, I'm not aware of any.

I think pppd is one such app (multilink and radius features may break), 
though this thread has only been concerned with eth devices so far. I'm 
sure I used a command line tool recently that was checking device names 
for eth%d patterns but I can't remember what it was now. :(

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

