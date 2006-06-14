From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.17: networking bug??
Date: Tue, 13 Jun 2006 21:25:34 -0400
Message-ID: <448F658E.9090903@psc.edu>
References: <448F0D4B.30201@rtr.ca>	<20060613.142603.48825062.davem@davemloft.net>	<448F32E1.8080002@rtr.ca> <20060613.152301.26928146.davem@davemloft.net> <448F3EF5.50701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:14273 "EHLO mailer1.psc.edu")
	by vger.kernel.org with ESMTP id S964867AbWFNBZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 21:25:55 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <448F3EF5.50701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> One final word about window sizes.  If you have a connection whose
>> bandwidth-delay-product needs an N byte buffer to fill, you actually
>> have to have an "N * 2" sized buffer available in order for fast
>> retransmit to work.
> 
> Is that as important in the presence of SACK?

With SACK you do need up to N * 2, but no more.  With New Reno, you 
potentially need ~ N * (number of losses) or it will time out... yuck. 
SACK is a good thing. :)

   -John
