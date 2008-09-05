From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 18:01:46 +0200
Message-ID: <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
References: <20080905113112.GA29926@2ka.mipt.ru>
	 <20080905131618.GB12246@2ka.mipt.ru>
	 <7e0dd21a0809050629w7fa8a914i863faa9ac18c3be4@mail.gmail.com>
	 <20080905133748.GA28656@2ka.mipt.ru>
	 <7e0dd21a0809050655n176ec32bo2bf4febe4e0fc363@mail.gmail.com>
	 <20080905141911.GA16586@2ka.mipt.ru>
	 <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
	 <20080905145902.GA12762@2ka.mipt.ru>
	 <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
	 <20080905153811.GA3596@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:61523 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753803AbYIEQBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 12:01:47 -0400
Received: by rv-out-0506.google.com with SMTP id k40so506422rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 09:01:46 -0700 (PDT)
In-Reply-To: <20080905153811.GA3596@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> Great, thank you. But it should take into account UDP nature: data is
> not allowed to be split between ip packets like with TCP.

I'm leaving office right now.
I'll come back toward you regarding this topic on Monday.

> Ethernet header is appended by the network core itself, likely core will
> just allocate skb with small data area, put there an ethernet and udp/ip
> headers and attach pages from the file. If hardware does not support
> checksumming and scatter/gather, things will be different.
>
>> App protocol must support packet loss ^^
>
> I think matter of packet loss relevance here is just the same like with
> any other sending method.
>

Ok, I see. I just need to check if UDP is fine for my application or
if i need to do my own L3/L4.

Many thanks again,
Have a nice weekend,

Johann

-- 
Johann Baudy
johaahn@gmail.com
