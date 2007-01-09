From: Komuro <komurojun-mbn@nifty.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Wed, 10 Jan 2007 07:01:27 +0900
Message-ID: <20070110070127.350d6742.komurojun-mbn@nifty.com>
References: <20061230185043.d31d2104.komurojun-mbn@nifty.com>
	<20061230.102358.106876516.yoshfuji@linux-ipv6.org>
	<20061230205931.9e430173.komurojun-mbn@nifty.com>
	<20061230.231952.16573563.yoshfuji@linux-ipv6.org>
	<20070105054546.953196e5.komurojun-mbn@nifty.com>
	<20070104122330.GA2233@craigdell.detnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>, bunk@stusta.de, jgarzik@pobox.com,
	viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:17947 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbXAINCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 08:02:09 -0500
To: Craig Schlenter <craig@codefountain.com>
In-Reply-To: <20070104122330.GA2233@craigdell.detnet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Jan 2007 14:23:30 +0200
Craig Schlenter <craig@codefountain.com> wrote:


> > --- linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c.orig	2007-01-03 11:50:04.000000000 +0900
> > +++ linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c	2007-01-03 15:30:44.000000000 +0900
> > @@ -648,7 +648,7 @@ static void tcp_v4_send_ack(struct tcp_t
> >  				   TCPOLEN_TIMESTAMP);
> >  		rep.opt[1] = htonl(tcp_time_stamp);
> >  		rep.opt[2] = htonl(ts);
> > -		arg.iov[0].iov_len = TCPOLEN_TSTAMP_ALIGNED;
> > +		arg.iov[0].iov_len = sizeof(rep);
> 
> Perhaps this was supposed to be
>                 arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;
> 
> That's what the ipv6 stuff does in places.

It works properly.
Thanks!


Best Regards
Komuro

