From: Rick Jones <rick.jones2@hp.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 11:00:48 -0700
Message-ID: <48B6E7D0.5070307@hp.com>
References: <21915755.1327801219904892242.JavaMail.root@ouachita>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Joe Malicki <jmalicki@metacarta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:11354 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751725AbYH1SAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 14:00:54 -0400
In-Reply-To: <21915755.1327801219904892242.JavaMail.root@ouachita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> What utility does the time of hitting the socket get you?

The earliest time the application could have been expected to start 
processing the request.  Until it hits the socket, it might as well be 
somewhere in the cloud.  By that reasoning of course, one could argue 
that a gettimeofday() call immediately following recv() would suffice.

Earlier in the thread mention was made of financial services types.  If 
someone has knowledge of the (probably) arcane rules under which they 
must operate it would be great to hear more.  Does some entity like the 
SEC (Securities and Exchange Commission in the United States) mandate 
some sort of timestamp for when the trading request "arrives at the 
trading system" and do they define that "arriving at the trading system" 
means?

rick jones
