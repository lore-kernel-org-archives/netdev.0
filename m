From: "Djalel Chefrour" <cdjalel@gmail.com>
Subject: Re: Does HTB traffic shaping happen on leaf classes only or could it happen at root qdisc
Date: Thu, 20 Mar 2008 15:07:05 +0100
Message-ID: <4a9dfdec0803200707v15f65d8oba1933f1b20e406c@mail.gmail.com>
References: <4a9dfdec0803180539wb2f9dc7n18cac81a2fe92345@mail.gmail.com>
	 <20080320115100.GB4037@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:18625 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755145AbYCTOHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 10:07:07 -0400
Received: by wf-out-1314.google.com with SMTP id 28so985059wff.4
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 07:07:06 -0700 (PDT)
In-Reply-To: <20080320115100.GB4037@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

THX for your reply.

>  > # tc -s -d class show dev ppp0
>  > class htb 1:110 parent 1:10 leaf 110: prio 0 quantum 1375 rate 110Kbit
>  > ceil 220Kbit burst 323b/2 mpu 0b overhead 18b atm cburst 392b/2 mpu 0b
>
>  Are these default quantum, burst and cburst parameters?
>
Yes they are. I forget to mention that I am also using tc-atm pacth with:
atm overhead 18 nohys mtu 256, for 1:10
atm overhead 18 nohys, for 1:20

>
>  > overhead 18b atm level 0
>  >  Sent 3888361 bytes 19368 pkts (dropped 0, overlimits 0)
>  >  rate 7160bit 35pps
>  >  lended: 19348 borrowed: 20 giants: 50
>
>  giants (>mtu) means something goes out of band here.
>
Hmmm, that could be explained with mtu set to 256

>
>  No, HTB root qdisc doesn't even have parameter for shaping.
>  BTW, did you read this fine manual?:
>  http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm
>

Yes, thats what I read too, but the output shows 0 overlimits for all
nodes but root !!!
So how to interpret this?

TIA

-- 
Dr Djalel Chefrour,
Software Consultant
