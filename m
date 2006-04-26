From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tune back idle cwnd closing?
Date: Wed, 26 Apr 2006 15:16:18 -0700
Message-ID: <444FF132.2080505@hp.com>
References: <44493980.1040708@oracle.com>	<444E31D9.1010705@psc.edu> <20060426.144540.39973302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, zach.brown@oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:57065 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S964905AbWDZWQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 18:16:21 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060426.144540.39973302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> When you're bursty application is not sending, other flows can take up
> the pipe space you are not using, and you must reprobe to figure that
> out.

If the "restarted" connection does normal slow-start, one of two things 
will happen yes?  Either it will grow its cwnd to >= the receiver's 
window, or it will have to stop before then because it triggered a 
packet loss.

In the first case, seems it would have been just as good to let the 
connection burst.

In the second case, is the effect on other connections really any better 
than if the connection just started-up from where it was before?

BTW, is the RFC 2681?  I looked that one up on ietf.org and the RFC by 
that number was a different beast entirely - at least at a very quick 
glance.

rick jones
