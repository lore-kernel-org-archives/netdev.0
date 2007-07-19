From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][RFC] network splice receive v3
Date: Thu, 19 Jul 2007 18:05:18 +0900 (JST)
Message-ID: <20070719.180518.79100322.yoshfuji@linux-ipv6.org>
References: <20070711091927.GQ4587@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	olaf.kirch@oracle.com, johnpol@2ka.mipt.ru, yoshfuji@linux-ipv6.org
To: jens.axboe@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S937842AbXGSJEu@vger.kernel.org>
In-Reply-To: <20070711091927.GQ4587@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070711091927.GQ4587@kernel.dk> (at Wed, 11 Jul 2007 11:19:27 +0200), Jens Axboe <jens.axboe@oracle.com> says:

> @@ -835,6 +835,7 @@ const struct proto_ops inet_stream_ops = {
>  	.recvmsg	   = sock_common_recvmsg,
>  	.mmap		   = sock_no_mmap,
>  	.sendpage	   = tcp_sendpage,
> +	.splice_read	   = tcp_splice_read,
>  #ifdef CONFIG_COMPAT
>  	.compat_setsockopt = compat_sock_common_setsockopt,
>  	.compat_getsockopt = compat_sock_common_getsockopt,

Please add similar bits in net/ipv6/af_inet6.c
unless there are any dependency on IPv4.
(And if there are, it is not good.)

--yoshfuji
