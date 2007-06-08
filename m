From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 11:00:08 -0700
Message-ID: <46699928.9060504@hp.com>
References: <OF7E8226CB.9B6FDC92-ON652572F4.003E9F60-652572F4.003F4BE0@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:57687 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764610AbXFHSAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 14:00:17 -0400
In-Reply-To: <OF7E8226CB.9B6FDC92-ON652572F4.003E9F60-652572F4.003F4BE0@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>Also note something else strange that it is kind of strange that
>>something like UDP which doesnt backoff will send out less
>>packets/second ;->
> 
> 
> Cannot explain that either :)

Perhaps delays in restarting after the intra-stack flow control is 
asserted.  One possible thing to do to try to deal with that a little 
would be to increase SO_SNDBUF in netperf with the -s option.  That at 
least is something I did back in 2.4 days

rick jones
