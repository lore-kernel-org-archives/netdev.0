From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Subject: RE: UDP Out 0f Sequence
Date: Thu, 21 Sep 2006 10:50:17 +0800
Message-ID: <F444CAE5E62A714C9F45AA292785BED30EB97599@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ln-bas08.csfb.com ([198.240.128.81]:40840 "EHLO
	ln-bas08.csfb.com") by vger.kernel.org with ESMTP id S1751016AbWIUCvA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 22:51:00 -0400
To: "'Rick Jones'" <rick.jones2@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Does this mean if we have 2 hosts connected back to back (there's no network device in between), sequence is guaranteed even in UDP? 

-----Original Message-----
From: Rick Jones [mailto:rick.jones2@hp.com]
Sent: 21 September 2006 00:47
To: Majumder, Rajib
Cc: 'netdev@vger.kernel.org'
Subject: Re: UDP Out 0f Sequence


Majumder, Rajib wrote:
> Hi,
> 
> If I write UDP datagrams 1,2 and 3 to network and if the receiver
> receives in order 2,1, and 3, where can the sequence get changed? Is it
> at the source stack, network transit or destination stack?

Yes. :)

Although network transit is by far the most likely case.  Destination 
stack is a distant second and source stack an even more distant third. 
Generally stack writers try to avoid having places in their stacks where 
things can reorder, but it isn't completely unknown.

rick jones


==============================================================================
Please access the attached hyperlink for an important electronic communications disclaimer: 

http://www.credit-suisse.com/legal/en/disclaimer_email_ib.html
==============================================================================

