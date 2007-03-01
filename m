From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 1 Mar 2007 13:03:26 +0300
Message-ID: <20070301100326.GA30537@2ka.mipt.ru>
References: <45E5570E.7050301@free.fr> <200702281455.27720.dada1@cosmosbay.com> <45E59062.6000103@free.fr> <200702281555.10309.dada1@cosmosbay.com> <45E5A8AE.3030606@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: John <linux.kernel@free.fr>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <45E5A8AE.3030606@free.fr>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 05:07:10PM +0100, John (linux.kernel@free.fr) wrote:
> Again, this is irrelevant. We are discussing whether it would make sense 
> to support sub-microsecond resolution. If there is one platform that can 
> achieve sub-microsecond precision, there is a need for sub-microsecond 
> resolution. As long as we are changing the resolution, we might as well 
> use something standard like struct timespec.

You can not blindly change skb timestamps to different entities - you
need to change all users (at least in kernel).
Exporting it to userspace must require new socket option and old one ust
be changed accordingly, but there is nothing wrong in having nanosecond
resolution in packet timestamp except that it might not be 100% correct
receiving time.

-- 
	Evgeniy Polyakov
