From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: zero copy with PACKET_MMAP
Date: Thu, 27 Feb 2014 10:58:30 +0100
Message-ID: <530F0C46.5040208@redhat.com>
References: <CAGZFCEF0RB2eHOfgVCyjVDEc4S+jHsdJ+-iQdbC3zek7G5Ahcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbaB0J6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 04:58:34 -0500
In-Reply-To: <CAGZFCEF0RB2eHOfgVCyjVDEc4S+jHsdJ+-iQdbC3zek7G5Ahcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2014 07:40 AM, ratheesh kannoth wrote:
...
> https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt
> talks about  achieving zero copy. But i find a deep  packet copy ( of
> length snaplen= skb->len )  here
> http://lxr.free-electrons.com/source/net/packet/af_packet.c#L1841.
>
> Is there anything missing/wrong in my understanding ?

The zero-copy is between user and kernel space.
