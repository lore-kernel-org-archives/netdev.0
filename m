From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Subject: RE: UDP Out 0f Sequence
Date: Thu, 21 Sep 2006 11:55:23 +0800
Message-ID: <F444CAE5E62A714C9F45AA292785BED30EB9759A@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-2.csfb.com ([198.240.128.81]:61057 "EHLO ln-bas08.csfb.com")
	by vger.kernel.org with ESMTP id S1751187AbWIUDzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 23:55:48 -0400
To: "'David Miller'" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let's say we have 2 uniprocessor hosts connected back to back. Is there any possibility of an out-of-order scenario on recv? Is this same for all kernel (linux/solaris)?  

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: 21 September 2006 11:51
To: rajib.majumder@credit-suisse.com
Cc: rick.jones2@hp.com; netdev@vger.kernel.org
Subject: Re: UDP Out 0f Sequence


From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Date: Thu, 21 Sep 2006 10:50:17 +0800

> Does this mean if we have 2 hosts connected back to back (there's no
> network device in between), sequence is guaranteed even in UDP?

Not true.  Even for back to back systems SMP can cause packets
to be delivered out of order even locally within the system
on receive.

==============================================================================
Please access the attached hyperlink for an important electronic communications disclaimer: 

http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
==============================================================================

