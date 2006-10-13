From: Kumar Gala <galak@kernel.crashing.org>
Subject: use of tx_timeout in enet driver?
Date: Fri, 13 Oct 2006 11:19:19 -0500
Message-ID: <E654CD0D-77A4-4B12-B2D5-FCB9ACFC191B@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:48364 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S1751666AbWJMQTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 12:19:10 -0400
Received: from cpe-66-69-212-100.austin.res.rr.com ([66.69.212.100] helo=[192.168.1.100])
	by nommos.sslcatacombnetworking.com with esmtp (Exim 4.52)
	id 1GYPkb-0003dJ-BX
	for netdev@vger.kernel.org; Fri, 13 Oct 2006 11:19:09 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm working on a enet driver and trying to figure out what I should  
do in the tx_timeout function.  The device I have doesn't interrupt  
on tx completions so I already have a timer loop to check to see if  
there have been any completions by looking at the ring pointers.

So should I do something like e100 does in using a work_queue to  
effectively reset the card if we get a tx_timeout?

- kumar
