From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] packet: nlmon: virtual netlink monitoring
 device for packet sockets
Date: Thu, 20 Jun 2013 10:07:10 +0200
Message-ID: <51C2B82E.9060401@redhat.com>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com> <1371665086-19677-4-git-send-email-dborkman@redhat.com> <20130619115941.34fc425e@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401Ab3FTIHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 04:07:37 -0400
In-Reply-To: <20130619115941.34fc425e@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/19/2013 08:59 PM, Stephen Hemminger wrote:
> On Wed, 19 Jun 2013 20:04:46 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>> Currently, there is no good possibility to debug netlink traffic that
>> is being exchanged between kernel and user space. Therefore, this patch
>> implements a netlink virtual device, so that netlink messages will be
>> made visible to PF_PACKET sockets. Once there was an approach with a
>> similar idea [1], but it got forgotten somehow.
>
> ip monitor all

Well, but this is only restricted to debugging rtnl and there are many other
subsystems using netlink. Also, it's not about low-level debugging netlink
in general from what I see from the code. So it's not really the same resp.
comparable to each other.
