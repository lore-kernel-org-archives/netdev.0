From: Nj A <nj_a83@yahoo.fr>
Subject: Re : Re : Re : Re : Bug in using inet_lookup ()
Date: Thu, 15 Nov 2007 16:57:17 +0000 (GMT)
Message-ID: <455140.87973.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web26108.mail.ukl.yahoo.com ([217.146.182.149]:30357 "HELO
	web26108.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754932AbXKOQ5T convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 11:57:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Well, your code will oops just like before - you provide empty skb to
> the inet_iif(), which is wrong. Actually you will not even reach that
> point, since your code will exit after skb->dev check.
> 
> Try simple inet_lookup(&tcp_hashinfo, src, p_src, dst, p_dst, 0).

But trying  inet_lookup(&tcp_hashinfo, src, p_src, dst, p_dst, 0), the machine either hangs or panics.

Is there any clean manner to come across this issue?


Cheers,


      _____________________________________________________________________________ 
Ne gardez plus qu'une seule adresse mail ! Copiez vos mails vers Yahoo! Mail 
