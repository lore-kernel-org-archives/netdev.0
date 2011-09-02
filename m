From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: interface information for recvd packet
Date: Thu, 1 Sep 2011 20:07:20 -0400
Message-ID: <CANX6DanmMVkANBNatJtusGLJcFCtp97oED6x=kJLXaLXFQZ42A@mail.gmail.com>
References: <CANX6Dan9szv1w8QTFTob53jt7Bq6jgTtbaHVirvBDJOjH7Uy+w@mail.gmail.com>
	<CANX6Dan5bdA-3wSiyAaQmOV6DHArxjknUFpR-s8coA9Yjx2N8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:46017 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932714Ab1IBAHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 20:07:20 -0400
Received: by pzk37 with SMTP id 37so3726833pzk.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2011 17:07:20 -0700 (PDT)
In-Reply-To: <CANX6Dan5bdA-3wSiyAaQmOV6DHArxjknUFpR-s8coA9Yjx2N8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Sep 1, 2011 at 3:40 PM, Viral Mehta <viral.vkm@gmail.com> wrote:
> On Tue, Aug 30, 2011 at 11:55 AM, Viral Mehta <viral.vkm@gmail.com> wrote:
>> 2. I was looking at net/ipv4/tcp.c and in function tcp_recvmsg(); I am
>> trying to get interface name by accessing sk_buff->dev->name
>
> I tried printing address of SKBs, but it gives different address in
> NIC driver and tcp.c
> My understanding is, struct sk_buff* remains same through out all
> layers i.e., NIC driver allocates it after receving frame
> and same is passed till TCP layer. But, apparently looks I am wrong
> from the prints that I have put.
>
> Can someone shed some light ?
>

Sorry for the noise. Also I got why nobody replied to my question :-)
Anyway, I was doing silly mistake while debugging the things; my
printks were at wrong place.

And everything works as expected and as per my understanding....
