From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 02 Oct 2007 17:07:40 +0200
Message-ID: <47025EBC.5000301@hartkopp.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131112.31727.5@janus.isnogud.escape.de> <20071002142016.GE7881@ghostprotocols.net>
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
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:31754 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbXJBPIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:08:11 -0400
In-Reply-To: <20071002142016.GE7881@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Oct 02, 2007 at 03:10:11PM +0200, Urs Thuermann escreveu:
>   
>
>> +
>> +/* To be moved to linux/can/dev.h */
>>     
>
> Is this comment still valid? If so can this move happen now? If not I
> think it would be better to stick a "FIXME: " just before it, no?
>
>   

Bringing all the current available CAN network device drivers into 
Kernel style qualitiy is a TODO for the time after the PF_CAN core is 
mainlined.

When more than this single vcan CAN netdev driver is part of the Kernel 
it makes sense to put several things (like the common configuration 
interface and commonly used library funtions for CAN drivers) into 
linux/can/dev.h. And at that time this currently local DEBUG definition 
should go there togehther with the other stuff.

Please think of all the comments, if we created a single dev.h file with 
a single DEBUG definition used by a single vcan.c file ;-)

Oliver

