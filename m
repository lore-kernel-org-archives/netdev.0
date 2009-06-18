From: Minoru Usui <usui@mxm.nes.nec.co.jp>
Subject: Re: [HELP] for using class group classifier network controller
Date: Thu, 18 Jun 2009 13:13:00 +0900
Message-ID: <20090618131300.14d575b8.usui@mxm.nes.nec.co.jp>
References: <d89801c9ef32$cdfcf480$8310fe81@etri.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <containers@lists.linux-foundation.org>,
	<tgraf@infradead.org>
To: "Chei-Yol Kim" <gauri@etri.re.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:39883 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbZFRFOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 01:14:22 -0400
In-Reply-To: <d89801c9ef32$cdfcf480$8310fe81@etri.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> when I set the classid to 0x10010, class 1:10's packet count was increased. 
> But, according to your configuration, every packet has to flowed to 1:10 class. 

Yes, you are right.

> Of course I know that the net_cls can't classify all packet because of the getting classid from the current task. 
> Even though we consider it, Many packets are flowed to 1:30 class. 
> therefore, the rate of the socket showed about 30mbps. This is the 1:30 class's rate.
> I think it's because that 1:30 class is the default class. 
> When I changed the default to 20, the rate was varied to 20mbps, class 1:20's rate.
>
> 
> To measure this rate, I used the iperf and scp command. Two results are the same.
> How about your experiment's result? 
> Would you check the accurate rate of the network using applications like a iperf?

I did same experience with nuttcp, I observed the same result, too.
(Almost packets were classified into default classid.)
 
> By the results of my experiments, net_cls couldn't control the network rate of the group. 
> What is your opinion?

I agree with you.
I'm going to investigate this problem. 

-- 
Minoru Usui <usui@mxm.nes.nec.co.jp>
