From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Re : Re : Re : Re : Bug in using inet_lookup ()
Date: Thu, 15 Nov 2007 20:30:58 +0300
Message-ID: <20071115173054.GA1606@2ka.mipt.ru>
References: <455140.87973.qm@web26108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net
To: Nj A <nj_a83@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55651 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755620AbXKORbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 12:31:08 -0500
Content-Disposition: inline
In-Reply-To: <455140.87973.qm@web26108.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 04:57:17PM +0000, Nj A (nj_a83@yahoo.fr) wrote:
> > Well, your code will oops just like before - you provide empty skb to
> > the inet_iif(), which is wrong. Actually you will not even reach that
> > point, since your code will exit after skb->dev check.
> > 
> > Try simple inet_lookup(&tcp_hashinfo, src, p_src, dst, p_dst, 0).
> 
> But trying  inet_lookup(&tcp_hashinfo, src, p_src, dst, p_dst, 0), the machine either hangs or panics.

Hmmm, it does not.
Please show at least one bug trace when inet_lookup(&tcp_hashinfo, 0, 0, 0, 0, 0) fails :)

> Is there any clean manner to come across this issue?

Yes, to show the code you are using.
Sorry, all mind readers are on vacations.

-- 
	Evgeniy Polyakov
