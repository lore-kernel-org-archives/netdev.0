From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: Tue, 02 Oct 2007 16:42:24 +0200
Message-ID: <470258D0.2040901@hartkopp.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131107.31727.1@janus.isnogud.escape.de> <20071002141138.GD7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:58658 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbXJBOm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:42:59 -0400
In-Reply-To: <20071002141138.GD7881@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Oct 02, 2007 at 03:10:07PM +0200, Urs Thuermann escreveu:
>   
>>
>> Index: net-2.6.24/include/linux/if_arp.h
>> ===================================================================
>> --- net-2.6.24.orig/include/linux/if_arp.h	2007-10-02 12:10:51.000000000 +0200
>> +++ net-2.6.24/include/linux/if_arp.h	2007-10-02 12:11:01.000000000 +0200
>> @@ -52,6 +52,7 @@
>>  #define ARPHRD_ROSE	270
>>  #define ARPHRD_X25	271		/* CCITT X.25			*/
>>  #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
>> +#define ARPHRD_CAN	280		/* Controller Area Network      */
>>     
>
> Is 280 used in other OS? Just curious as why not using 273
>
>   

All these definitions (PF_*, AF_*, ARPHRD_* ) are operation system 
specific (that's why you find it in /usr/include/linux/*.h :)

I just googled for AF_INET and found that e.g.
AF_APPLETALK is "16" in winsock.h and "5" in include/linux/socket.h

The reason to use 280 instead of 273 was, that all the 27x stuff was 
dedicated to the X.25 domain. So to start with a new 280 looked 
reasonable to me.

At the end of the ARPHRD_* definitions there's currently many 'change 
traffic' due to IEEE80211.

Oliver

