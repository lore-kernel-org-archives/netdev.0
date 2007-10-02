From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 2 Oct 2007 13:46:21 -0300
Message-ID: <20071002164621.GA3576@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131112.31727.5@janus.isnogud.escape.de> <20071002142016.GE7881@ghostprotocols.net> <47025EBC.5000301@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:40265 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669AbXJBQqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 12:46:34 -0400
Received: by nf-out-0910.google.com with SMTP id g13so3318306nfb
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 09:46:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47025EBC.5000301@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 02, 2007 at 05:07:40PM +0200, Oliver Hartkopp escreveu:
> Arnaldo Carvalho de Melo wrote:
>> Em Tue, Oct 02, 2007 at 03:10:11PM +0200, Urs Thuermann escreveu:
>>   
>>> +
>>> +/* To be moved to linux/can/dev.h */
>>>     
>>
>> Is this comment still valid? If so can this move happen now? If not I
>> think it would be better to stick a "FIXME: " just before it, no?
>>
>>   
>
> Bringing all the current available CAN network device drivers into Kernel 
> style qualitiy is a TODO for the time after the PF_CAN core is mainlined.
>
> When more than this single vcan CAN netdev driver is part of the Kernel it 
> makes sense to put several things (like the common configuration interface 
> and commonly used library funtions for CAN drivers) into linux/can/dev.h. 
> And at that time this currently local DEBUG definition should go there 
> togehther with the other stuff.
>
> Please think of all the comments, if we created a single dev.h file with a 
> single DEBUG definition used by a single vcan.c file ;-)

Don't get to defensive. You know a lot more than me about the code you
worked for that many years. Its just that it looked suspicious for a
casual reviewer. :-)

- Arnaldo
