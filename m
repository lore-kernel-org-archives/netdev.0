From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Free TCP/IP stack to be used
Date: Sun, 20 Jul 2008 01:01:41 +0400
Message-ID: <20080719210140.GA12119@2ka.mipt.ru>
References: <a967d7d00807191356v5dbd0397web585bae1598ee9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Keyur Chudgar <kchudgar.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36749 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbYGSVBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jul 2008 17:01:44 -0400
Content-Disposition: inline
In-Reply-To: <a967d7d00807191356v5dbd0397web585bae1598ee9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sat, Jul 19, 2008 at 01:56:07PM -0700, Keyur Chudgar (kchudgar.linux@gmail.com) wrote:
> I am looking for free TCP/IP stack to be used in my system.
> Can anybody suggest which one I should go for? It should be
> light weight and not like Linux TCP/IP stack. I came across
> LwIP, but I am not sure about it's performance.

What system, what load, what ...?
Your question is quite incomplete :)

Anyway, I will advertise following userspace network stack (works either
on top of packet socket or own packet reading/writing interface, so if
you are creating your own kernel, the only thing you need is to create a
channel to driver to be able to send and receive packets into the
queue):
http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack

It supports TCP/UDP over IP, but you can extend it whatever you like,
It is licensed under GPLv2 or higher.

-- 
	Evgeniy Polyakov
