From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net] skge: dma_sync the whole receive buffer
Date: Fri, 16 Aug 2013 16:36:39 +0200
Message-ID: <520E38F7.1080407@gmail.com>
References: <20130810104100.0ae20aa6@nehalam.linuxnetplumber.net> <20130810.132935.1257046025460198490.davem@davemloft.net> <20130810150207.37432299@nehalam.linuxnetplumber.net> <20130813.150955.1471100759610399160.davem@davemloft.net> <20130813180036.3e639789@nehalam.linuxnetplumber.net> <520B59D3.4020103@gmail.com> <20130814092022.494caf2b@nehalam.linuxnetplumber.net> <520BCC72.8040002@gmail.com> <20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:62590 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab3HPOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 10:36:42 -0400
Received: by mail-ea0-f181.google.com with SMTP id d10so1032322eaj.26
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 07:36:41 -0700 (PDT)
In-Reply-To: <20130815084117.2f48fc58@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.08.2013 17:41, Stephen Hemminger wrote:

> In the course of debugging this, I moved the card to another slot
> and all the problems went away. I suspect either card insertion or more likely
> the crap consumer motherboards don't have full PCI support on some slots.
> 
> There doesn't seem to be anyway to address this in software.
> 

Noted, thanks.
Follows overhaul.


poma
