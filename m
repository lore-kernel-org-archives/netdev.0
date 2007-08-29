From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 18:52:48 -0400
Message-ID: <46D5F8C0.4080801@psc.edu>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>	<20070829.144656.104048365.davem@davemloft.net>	<46D5F32F.2070502@hp.com> <20070829.153503.18295527.davem@davemloft.net> <46D5F7C8.8090806@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ian.mcdonald@jandi.co.nz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56445 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758315AbXH2Wwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:52:53 -0400
In-Reply-To: <46D5F7C8.8090806@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
>> What exactly causes such a huge delay?  What is the TCP measured RTO
>> in these circumstances where spurious RTOs happen and a 3 second
>> minimum RTO makes things better?
> 
> I haven't done a lot of work on wireless myself, but my understanding is 
> that one of the biggest problems is the behavior link-layer 
> retransmission schemes.  They can suddenly increase the delay of packets 
> by a significant amount when you get a burst of radio interference. It's 
> hard for TCP to gracefully handle this kind of jump without some minimum 
> RTO, especially since wlan RTTs can often be quite small.

(Replying to myself) Though F-RTO does often help in this case.

   -John
