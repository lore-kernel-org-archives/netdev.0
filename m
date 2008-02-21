From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Thu, 21 Feb 2008 13:00:29 +0100
Message-ID: <47BD67DD.6020404@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net>	 <1203431447.3223.33.camel@shinybook.infradead.org>	 <47BAEB6C.1030609@trash.net> <1203594725.15409.48.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep31-int.chello.at ([62.179.121.49]:63497 "EHLO
	viefep31-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753449AbYBUMAx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 07:00:53 -0500
In-Reply-To: <1203594725.15409.48.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Tue, 2008-02-19 at 15:45 +0100, Patrick McHardy wrote:
>> That would break iptables compilation, which already includes
>> linux/in.h in some files. I guess the best fix for now is to
>> include netinet/in.h in busybox and long-term clean this up
>> properly.
> 
> Yeah, that makes sense.
> 
> Can we push the change to __u32 (or uint32_t) for 2.6.24? Or is there
> something obvious we should be doing in busybox which we aren't? I don't
> quite understand why this u_int32_t crap doesn't work at _all_ when it
> evidently used to at least in some environments.


I already sent it to Dave for 2.6.25 (I assume that what you meant,
it was introduced after 2.6.24), its currently sitting in net-2.6
and should hit Linus' tree next time he pulls from Dave.


