From: Rick Jones <rick.jones2@hp.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Thu, 10 Jan 2008 10:41:56 -0800
Message-ID: <478666F4.50405@hp.com>
References: <478654C3.60806@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:19966 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754313AbYAJSl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 13:41:58 -0500
In-Reply-To: <478654C3.60806@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 1) Interrupts are being processed on both cpus:
> 
> root@base0-0-0-13-0-11-1:/root> cat /proc/interrupts
>            CPU0       CPU1
>  30:    1703756    4530785  U3-MPIC Level     eth0

IIRC none of the e1000 driven cards are multi-queue, so while the above 
shows that interrupts from eth0 have been processed on both CPUs at 
various points in the past, it doesn't necessarily mean that they are 
being processed on both CPUs at the same time right?

rick jones
