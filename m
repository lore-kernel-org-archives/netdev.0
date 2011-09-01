From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: interface information for recvd packet
Date: Thu, 1 Sep 2011 15:40:12 -0400
Message-ID: <CANX6Dan5bdA-3wSiyAaQmOV6DHArxjknUFpR-s8coA9Yjx2N8A@mail.gmail.com>
References: <CANX6Dan9szv1w8QTFTob53jt7Bq6jgTtbaHVirvBDJOjH7Uy+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:58665 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757651Ab1IATkN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 15:40:13 -0400
Received: by pzk37 with SMTP id 37so3434672pzk.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 12:40:12 -0700 (PDT)
In-Reply-To: <CANX6Dan9szv1w8QTFTob53jt7Bq6jgTtbaHVirvBDJOjH7Uy+w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2011 at 11:55 AM, Viral Mehta <viral.vkm@gmail.com> wro=
te:
>
> Hi,
>
> I was trying to implement following thing,
>
> 1. I wanted to know whenever packet received for particular socket, I
> want to know which network interface actually received it ?

My objective is still the same..

> 2. I was looking at net/ipv4/tcp.c and in function tcp_recvmsg(); I a=
m
> trying to get interface name by accessing sk_buff->dev->name

I tried printing address of SKBs, but it gives different address in
NIC driver and tcp.c
My understanding is, struct sk_buff* remains same through out all
layers i.e., NIC driver allocates it after receving frame
and same is passed till TCP layer. But, apparently looks I am wrong
from the prints that I have put.

Can someone shed some light ?

> =A0 =A0However, it gives me (null). I have made sure that in my ether=
net
> (NIC) driver, I filled up that information before doing netif_rx().
>
> So, the question is,
> Is this information Trimmed out at some upper layer ??
>

--
Thanks,
Viral Mehta
