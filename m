From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v3
Date: Thu, 19 Jul 2007 11:07:31 +0200
Message-ID: <20070719090730.GD11657@kernel.dk>
References: <20070711091927.GQ4587@kernel.dk> <20070719.180518.79100322.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	olaf.kirch@oracle.com, johnpol@2ka.mipt.ru
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:25381 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751507AbXGSJHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 05:07:50 -0400
Content-Disposition: inline
In-Reply-To: <20070719.180518.79100322.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19 2007, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> Hello.
> 
> In article <20070711091927.GQ4587@kernel.dk> (at Wed, 11 Jul 2007 11:19:27 +0200), Jens Axboe <jens.axboe@oracle.com> says:
> 
> > @@ -835,6 +835,7 @@ const struct proto_ops inet_stream_ops = {
> >  	.recvmsg	   = sock_common_recvmsg,
> >  	.mmap		   = sock_no_mmap,
> >  	.sendpage	   = tcp_sendpage,
> > +	.splice_read	   = tcp_splice_read,
> >  #ifdef CONFIG_COMPAT
> >  	.compat_setsockopt = compat_sock_common_setsockopt,
> >  	.compat_getsockopt = compat_sock_common_getsockopt,
> 
> Please add similar bits in net/ipv6/af_inet6.c
> unless there are any dependency on IPv4.
> (And if there are, it is not good.)

There are no specific ipv4 depedencies, it's just an oversight. So
thanks for the clue, I'll add it!

-- 
Jens Axboe

