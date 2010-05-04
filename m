From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Mon, 03 May 2010 23:22:49 -0700 (PDT)
Message-ID: <20100503.232249.200767273.davem@davemloft.net>
References: <4BDF8387.4000303@hp.com>
	<20100503.230553.200626786.davem@davemloft.net>
	<AANLkTingTdmhyJhENb9AYDjUT7m_-yQflw5-gJqIA9iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: enh@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53693
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755459Ab0EDGWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 02:22:42 -0400
In-Reply-To: <AANLkTingTdmhyJhENb9AYDjUT7m_-yQflw5-gJqIA9iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: enh <enh@google.com>
Date: Mon, 3 May 2010 23:19:22 -0700

> for the *unicast* hops, a part of the RFC i didn't quote says:
> 
>    If the [IPV6_UNICAST_HOPS] option is not set, the
>    system selects a default value.
> 
> but for the *multicast* hops, which is what i'm talking about, this
> part of the quoted text seems pretty definitive:
> 
>            If IPV6_MULTICAST_HOPS is not set, the default is 1
>            (same as IPv4 today)
> 
> this is what my test shows isn't true of linux; linux reuses its
> unicast default instead.

Ok, I see, so yeah this needs to be fixed to use "1" instead of
"-1" in the np->xxx ipv6 socket initialization.
