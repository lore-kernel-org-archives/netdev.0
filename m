From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: how to test multipe unicast MAC address
Date: Mon, 08 Apr 2013 07:16:44 -0700
Message-ID: <1365430604.3887.8.camel@edumazet-glaptop>
References: <CAJ3bTp6xYkKwXNm_YZ9DTy9G8wdKqKEBQOVRjaGkmMURG2MaEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:54170 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936054Ab3DHOQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 10:16:47 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so2624119dan.38
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 07:16:46 -0700 (PDT)
In-Reply-To: <CAJ3bTp6xYkKwXNm_YZ9DTy9G8wdKqKEBQOVRjaGkmMURG2MaEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 12:38 +0530, Rayagond K wrote:
> Hi All,
> 
> How to assign multiple unicast MAC address to single interface ?
> How to test multiple unicast MAC address filtering ?
> 
> Thanks in advance.
> 

Standard way would be to use macvlan

ip link add link eth0 name foo02 addr 44:44:44:44:00:02 type macvlan
ip link add link eth0 name foo03 addr 44:44:44:44:00:03 type macvlan
