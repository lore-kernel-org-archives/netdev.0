From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] vxlan: listen on multiple ports
Date: Fri, 17 May 2013 21:05:17 -0700
Message-ID: <20130517210517.04a36665@nehalam.linuxnetplumber.net>
References: <20130516143520.581d1d78@nehalam.linuxnetplumber.net>
	<20130517.140655.2182995212892285929.davem@davemloft.net>
	<CAOaVG15gx4Fqgqwjg5v-k=r4FrVNgTh9EpnnmxGECc5Wv_X=wA@mail.gmail.com>
	<OF0A8D9398.8E59B8DA-ON85257B6F.0014B0DC-85257B6F.0015E329@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35268 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab3EREFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 00:05:22 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so3174767pdj.28
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 21:05:22 -0700 (PDT)
In-Reply-To: <OF0A8D9398.8E59B8DA-ON85257B6F.0014B0DC-85257B6F.0015E329@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 May 2013 23:59:03 -0400
David Stevens <dlstevens@us.ibm.com> wrote:

> Stephen Hemminger <stephen@networkplumber.org> wrote on 05/17/2013 
> 11:05:16 PM:
> 
> > then the original commit to add NDA_PORT should be reverted from 3.10
> > no point in continuing the half baked idea
> 
> I don't think these are linked at all. While being able to specify
> multiple listen ports, I agree, is a good idea, being able to specify
> alternate remote ports is needed because you can already change the
> one per-host port.
> 
> With only one listen port per host, if they are different on two hosts,
> NDA_PORT in the fdb table is the only way those two hosts can use VXLAN
> with each other at all.
> 
> It has nothing to do with how many listen ports there are, but just that
> the listen port can be different on different hosts.
> 
>                                                                 +-DLS
> 

It does mean that you are creating an asymmetric routing setup.
The other end of the tunnel still has to send back to default vxlan port.
There is no mechanism to add additional ports.
