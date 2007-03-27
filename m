From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [SK_BUFF]: Introduce skb_copy_from_linear_data{_offset}
Date: Tue, 27 Mar 2007 23:35:07 +0200
Message-ID: <46098E0B.4030805@trash.net>
References: <20070327194148.GC20303@ghostprotocols.net>	 <20070327.140749.106434705.davem@davemloft.net>	 <39e6f6c70703271422i3881fc6bw18480e8f1b553e27@mail.gmail.com>	 <46098B74.8060404@trash.net> <39e6f6c70703271433h5ce06dabv521eaa4436727164@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35092 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965521AbXC0VgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 17:36:20 -0400
In-Reply-To: <39e6f6c70703271433h5ce06dabv521eaa4436727164@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> On 3/27/07, Patrick McHardy <kaber@trash.net> wrote:
> 
>> nf_nat_helper.c:mangle_content() could make use of this, but it
>> would need memmove. Something to do this with non-linear packets
>> would be even cooler :)
> 
> 
> Damn, that was so fast man! For the qeth case that motivated me to try
> the leftover it was like: memcpy is the fastest way, memmove would be
> more costly but more general, when in doubt I just droppped the users
> without removing the infrastructure, nah, lets leave this for another
> day, for now I'll just drop the non-used -new infrastrucure and
> resubmit.


Yes, as long as it doesn't help with anything else it doesn't seem
too useful. It did motivate me to try the non-linear skb mangling
though :)

