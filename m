From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next 3/3] packet: nlmon: virtual netlink
 monitoring device for packet sockets
Date: Wed, 19 Jun 2013 11:59:41 -0700
Message-ID: <20130619115941.34fc425e@samsung-9>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
	<1371665086-19677-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:64545 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385Ab3FSS7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 14:59:45 -0400
Received: by mail-pd0-f176.google.com with SMTP id t12so5343287pdi.7
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 11:59:45 -0700 (PDT)
In-Reply-To: <1371665086-19677-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Jun 2013 20:04:46 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> Currently, there is no good possibility to debug netlink traffic that
> is being exchanged between kernel and user space. Therefore, this patch
> implements a netlink virtual device, so that netlink messages will be
> made visible to PF_PACKET sockets. Once there was an approach with a
> similar idea [1], but it got forgotten somehow.

ip monitor all
