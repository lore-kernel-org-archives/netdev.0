From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: [1/4] kevent: core files.
Date: Sat, 24 Jun 2006 11:14:13 +0200
Message-ID: <7e63f56c0606240214g1b67539ajf0eb99ecd832c9fc@mail.gmail.com>
References: <20060623070933.GA20291@2ka.mipt.ru>
	 <20060623184457.GA13617@kvack.org>
	 <20060623192422.GA11508@2ka.mipt.ru>
	 <20060623.131940.48806210.davem@davemloft.net>
	 <20060623203114.GD14126@kvack.org>
	 <20060623205401.GB26168@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Benjamin LaHaise" <bcrl@kvack.org>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:4620 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932998AbWFXJOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Jun 2006 05:14:14 -0400
Received: by nf-out-0910.google.com with SMTP id h2so286293nfe
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2006 02:14:13 -0700 (PDT)
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
In-Reply-To: <20060623205401.GB26168@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> According to numbers: kevent compared to epoll resulted in the
> folllowing numbers:
> kevent: more than 2600 requests per second (trivial web server)
> epoll: about 1600-1800 requests.
> Number of errors for 3k bursts of connections with 30K connections total
> in 10seconds:
> kevent: about 2k errors.
> epoll: upto 15k errors.

If it beats the great epoll, it means a real business case for kevent.

All previous attempts in kernel as well as by glibc and other userland
emulations to provide some real AIO infrastructure and API for server
applications with performance benefits, were not too much successful.
Heavy load networking servers are normally not using AIOs on linux due
to low performance.

>From another side Windows have a very strong I/O completion ports API,
which are widely used for the most heavy load applications.

Kevent may take linux servers productivity forward in general as well as
encourage moving aio-applications from windows to linux.

-- 
Sincerely,
------------------------------------------------------------------
Robert Iakobashvili, coroberti at gmail dot com
Navigare necesse est, vivere non est necesse.
------------------------------------------------------------------
