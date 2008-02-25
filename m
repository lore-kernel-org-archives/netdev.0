From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Mon, 25 Feb 2008 13:12:10 +0100
Message-ID: <47C2B09A.1040102@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net>	 <1203431447.3223.33.camel@shinybook.infradead.org>	 <47BAEB6C.1030609@trash.net>	 <1203666762.5771.35.camel@shinybook.infradead.org>	 <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org>	 <47BEEDEF.5060503@trash.net> <1203719866.5771.81.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:54409 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754054AbYBYMMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 07:12:16 -0500
In-Reply-To: <1203719866.5771.81.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Fri, 2008-02-22 at 16:44 +0100, Patrick McHardy wrote:
>> Pablo Neira Ayuso wrote:
>>> Patrick McHardy wrote:
>>>> Yes, that was a bug in the lastest release. We need to
>>>> release a 1.4.1 version or something like that, but I'm
>>>> not too familiar with the release process, so I haven't
>>>> done this so far.
>>> I can schedule one for this weekend, just send me an ACK.
>>
>> That would be great. I think we had another issue in 1.4.0 with
>> some header files, but I can't remeber the details.
> 
> If you are going to include header files in the release (which makes a
> certain amount of sense), it would be best if those are simply the
> result of the kernel's 'make headers_install', without any manual
> changes.


Yes, the kernel headers need to be fixed as well to not include
linux/compiler.h outside of #ifdef __KERNEL__. I'll take care
of that.

