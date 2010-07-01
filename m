From: Sathya Perla <sathyap@serverengines.com>
Subject: Re: [net-next-2.6 PATCH] be2net: memory barrier fixes on IBM p7
 platform
Date: Thu, 01 Jul 2010 11:53:55 +0530
Message-ID: <1277965435.4345.0.camel@ubuntu.ubuntu-domain>
References: <20100629101117.GA2338@serverengines.com>
	 <20100630.132749.218066997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:3597 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab0GAGYT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 02:24:19 -0400
In-Reply-To: <20100630.132749.218066997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 13:27 -0700, David Miller wrote:
> > -
> > +	
> > +	rmb();
> 
> That first addition does nothing but add erroneous trailing
> whitespace.
> 
> You can physically see that something must be wrong here just by look
> at this patch chunk, please review things more thoroughly before
> submitting in the future.
> 
Will do, thanks.



___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

