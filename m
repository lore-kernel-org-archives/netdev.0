From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Wed, 10 Sep 2008 01:11:31 +0200
Message-ID: <7e0dd21a0809091611q74b032ffw734d031a4def894b@mail.gmail.com>
References: <7e0dd21a0809050745w692328b7v6dd4e0adf59e9535@mail.gmail.com>
	 <7e0dd21a0809050830o7c1dcc2do68da5df9900fcfe8@mail.gmail.com>
	 <20080905153811.GA3596@2ka.mipt.ru>
	 <7e0dd21a0809050901q23d0b16xa1a9d0df2f36f6d8@mail.gmail.com>
	 <20080905163446.GB10078@2ka.mipt.ru>
	 <7e0dd21a0809080321p6b9e2bc7m73e2cdd57a8d58b8@mail.gmail.com>
	 <20080908112629.GA26488@2ka.mipt.ru>
	 <7e0dd21a0809080601lc250197wde17733522d03125@mail.gmail.com>
	 <20080908152835.GA16834@2ka.mipt.ru>
	 <20080908153841.GA24683@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:10862 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311AbYIIXLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 19:11:32 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2105531rvb.1
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2008 16:11:31 -0700 (PDT)
In-Reply-To: <20080908153841.GA24683@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

We've performed more tests with additional and mandatory processes of
our system. Bitrate and CPU performance were very very low. This
result leads us to brainstorm on a new system design that meets
specifications target. I'll continue these tests once new design
ready.

Concerning udp_sendpage() patch, if you agree, I will suggest this
patch to the community in a new thread.

Many thanks for your help,
Johann



On Mon, Sep 8, 2008 at 5:38 PM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Mon, Sep 08, 2008 at 07:28:35PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>> What is CPU usage on sender when it sends data via UDP sendfile()?
>
> Actually we can determine the culprit via putting a loop into
> udp_sendpage(), which will send the same data. if receiver will see the
> same delayes, problem in the udp sending path, otherwise in splice code.
>
> --
>        Evgeniy Polyakov
>



-- 
Johann Baudy
johaahn@gmail.com
