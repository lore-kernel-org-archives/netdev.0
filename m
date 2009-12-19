From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [0/5]
Date: Sat, 19 Dec 2009 10:45:32 +0100
Message-ID: <4B2CA0BC.5080905@uniroma2.it>
References: <4B2B5BD1.7040602@uniroma2.it> <20091218.200406.183057577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fabio.ludovici@yahoo.it,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:57208 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbZLSJpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Dec 2009 04:45:39 -0500
In-Reply-To: <20091218.200406.183057577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> The patch is backward compatible, we have not removed the previous...
> 
> To heck it is!
> The changed version of iproute2 will not work without the kernel
> changes installed.  The kernel validates the size of the structures
> passed in, you can't change the user visible interface like this.

David Miller wrote:
 > Furthermore it is fundamentally flawed in it's implementation
 > in that the user exported data structures cannot be changed,
 > you cannot change the layout and you absolutely cannot
 > change the size of these things or else various tool and
 > kernel combinations stop working.

thank you for raising these fundamental issues !
we will address them and resubmit the patch when done...

 > Add new netlink attributes to extend things, that's the "real"
 > backwards compatible way to make changes to netlink interfaces.

point taken

-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
