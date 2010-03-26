From: Haile Seifu <haile.seifu@gmail.com>
Subject: Re: IPv6 neighbor advertisements
Date: Fri, 26 Mar 2010 10:40:08 -0400
Message-ID: <aa711df21003260740pd1ba598xdcbd536e0a3fb690@mail.gmail.com>
References: <aa711df21003252251x524d7dd2hac4a88103d0ae3a@mail.gmail.com>
	 <20100325.230733.214002385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:57785 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab0CZOkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 10:40:09 -0400
Received: by pzk32 with SMTP id 32so2634167pzk.4
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 07:40:08 -0700 (PDT)
In-Reply-To: <20100325.230733.214002385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


Yes, but the neighbor entry can be checked for the protocol type and
then the confirmed/updated field can be reset if the else condition is
taken.


On Fri, Mar 26, 2010 at 2:07 AM, David Miller <davem@davemloft.net> wrote:
>
> Keep in mind that net/core/neighbour.c is for IPV4 ARP too.
>
> So if there is a conflict between what is allowed by ipv4
> and what is allowed by ipv6 in this scenerio, that would
> explain it.
>
