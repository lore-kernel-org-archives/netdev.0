From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: network card with LRO (and TSO) in hardware?
Date: Thu, 29 May 2008 21:11:01 +0300
Message-ID: <200805292111.01690.opurdila@ixiacom.com>
References: <200805292004.58064.opurdila@ixiacom.com> <483EE9B3.80201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:2999 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753153AbYE2SMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 14:12:13 -0400
In-Reply-To: <483EE9B3.80201@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 May 2008, Rick Jones wrote:
>
> That second bit sounds very much like a "how long is a piece of string"
> question.  What size packets?  What sort of host system(s)?  How many
> concurrent flows/connections etc etc etc...
>

No restrictions... Any packet size (though I presume the lower the better), 
any kind of host systems, any number of concurrent flows (though I presume 
the fewer the better). I am just wondering what is the maximum packet rate 
ever seen by somebody, with hardware LRO.

I am asking this because, theoretically, with hardware LRO we should be able 
to achieve a very high packet rate when using a low MTU (like 64 or 128 
bytes). With software LRO I got a significant PPS increase for TCP traffic - 
from 100K (that with terrible hacks - generating traffic from kernel)  to 
140K (that cleanly, from user-space). So I am wondering what the hardware LRO 
will do.

Thanks,
tavi

