From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next 3/3] packet: nlmon: virtual netlink
 monitoring device for packet sockets
Date: Thu, 20 Jun 2013 08:46:53 -0700
Message-ID: <20130620084653.4d11dd3e@nehalam.linuxnetplumber.net>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
	<1371665086-19677-4-git-send-email-dborkman@redhat.com>
	<20130619115941.34fc425e@samsung-9>
	<51C2B82E.9060401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:61581 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757106Ab3FTPq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:46:58 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so6422095pdj.28
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 08:46:57 -0700 (PDT)
In-Reply-To: <51C2B82E.9060401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Jun 2013 10:07:10 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> On 06/19/2013 08:59 PM, Stephen Hemminger wrote:
> > On Wed, 19 Jun 2013 20:04:46 +0200
> > Daniel Borkmann <dborkman@redhat.com> wrote:
> >
> >> Currently, there is no good possibility to debug netlink traffic that
> >> is being exchanged between kernel and user space. Therefore, this patch
> >> implements a netlink virtual device, so that netlink messages will be
> >> made visible to PF_PACKET sockets. Once there was an approach with a
> >> similar idea [1], but it got forgotten somehow.
> >
> > ip monitor all
> 
> Well, but this is only restricted to debugging rtnl and there are many other
> subsystems using netlink. Also, it's not about low-level debugging netlink
> in general from what I see from the code. So it's not really the same resp.
> comparable to each other.

I was thinking that having a more general monitor is great, and maybe you
could reuse the similar concepts that already exist. I like the device idea
or maybe teaching libpcap how to handle another input source like Patrick's
mmap netlink would be better.
