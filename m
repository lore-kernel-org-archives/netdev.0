From: Patrick McHardy <kaber@trash.net>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 22:31:20 +0200
Message-ID: <48387B18.2090300@trash.net>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>	 <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com>	 <1211569604.11907.37.camel@perihelion>	 <20080523225435.GT20815@postel.suug.ch>	 <1211603155.11907.79.camel@perihelion>	 <alpine.LNX.1.10.0805240646380.19084@fbirervta.pbzchgretzou.qr>	 <20080524051630.GD20890@auslistsprd01.us.dell.com>	 <4837DCA4.5070806@katalix.com> <1211621632.31212.73.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
	Matt Domsch <Matt_Domsch@dell.com>,
	Jan Engelhardt <jengelh@medozas.de>,
	Jon Masters <jonathan@jonmasters.org>,
	Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44247 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbYEXUbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 16:31:24 -0400
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

iptraf uses device names to determine the device type:

char ifaces[][6] =
     { "lo", "eth", "sl", "ppp", "ippp", "plip", "fddi", "isdn", "dvb",
     "pvc", "hdlc", "ipsec", "sbni", "tr", "wvlan", "wlan", "sm2", "sm3",
     "pent", "lec", "brg", "tun", "tap", "cipcb", "tunl", "vlan", "ath",
     "ra"
};

and

         if (strncmp(ifname, "eth", 3) == 0)
             result = LINK_ETHERNET;
         else if (strncmp(ifname, "ath", 3) == 0)
             result = LINK_ETHERNET;
         else if (strncmp(ifname, "plip", 4) == 0)
             result = LINK_PLIP;
...
