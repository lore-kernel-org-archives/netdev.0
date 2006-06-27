From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tg3 driver and interrupt coalescence questions
Date: Tue, 27 Jun 2006 11:33:55 -0700
Message-ID: <44A17A13.8090704@hp.com>
References: <44A167EB.8000805@netgeeks.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:17329 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1030279AbWF0Sd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 14:33:59 -0400
To: "Chris A. Icide" <chris@netgeeks.net>
In-Reply-To: <44A167EB.8000805@netgeeks.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris A. Icide wrote:
> I've been digging around trying to get some information on the
> current status of interrupt mitigation features for a Braodcom 5704 interface.
> 
> Specifically I'm sending and receiving lots of VoIP packets (50 pps
 > per stream, many streams).
> 
> What I can't seem to determine is this:
> 
> What version of the linux kernel & tg3 drivers are required to
> support both rx and tx mitigation?
> What do the ethtool coalescence settings actually do (I've not been

Delay interrupts and increase individual packet latency with the 
intention being decreasing CPU utilization and allowing a higher 
aggregate packet per second limit.  IE bandwidth vs latency tradeoffs.

> able to find actual descriptions of the different parameters in the -C
> section)
> Is there anything special that needs to be done when compiling a
> kernel to enable this feature for both the kernel and the tg3 driver.

Are you looking to increase or decrease the settings?  I would think 
(initially at least) that for VOIP one might not want to increase them.

rick jones
