From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 07:39:05 -0700
Message-ID: <46F7CC09.6070603@candelatech.com>
References: <46F6905C.6030309@opengridcomputing.com>	 <20070923172803.GA11997@2ka.mipt.ru>	 <46F6A887.1030301@opengridcomputing.com> <1190571527.4256.78.camel@localhost> <46F75968.4010307@candelatech.com> <46F7C185.1030202@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, Robert Olsson <Robert.Olsson@data.slu.se>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:55406 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbXIXOj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 10:39:27 -0400
In-Reply-To: <46F7C185.1030202@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> I think pktgen should be cloning the skbs using skb_clone().  Then it 
> will work for all devices, eh?
That might work, but it would decrease performance slightly (or, 
increase CPU load at least).

Maybe a new option:  multi_clone

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


