From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Mon, 7 Dec 2015 11:48:30 +0100
Message-ID: <20151207114830.78912df5@griffin>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
	<CALx6S35_CbKfNpGJM6xsSgdkd25iekMCS3jwyG7_B5bCfeJhQw@mail.gmail.com>
	<20151204180610.51732e36@griffin>
	<CALx6S34_MazNmhACWBnVYFzXT9qZPLy2CZK3BBhP8RJzoHYo4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896AbbLGKse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 05:48:34 -0500
In-Reply-To: <CALx6S34_MazNmhACWBnVYFzXT9qZPLy2CZK3BBhP8RJzoHYo4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<On Fri, 4 Dec 2015 09:13:28 -0800, Tom Herbert wrote:
> That's awesome! One favor, can you make sure VXLAN-GPE works with IPv6
> from the start. :-)

Absolutely. I've not spent so much effort adding IPv6 counterparts to
various vxlan stuff to submit vxlan-gpe for IPv4 only :-)

> Also, I'll need to spin an I-D for RCO in VXLAN-GPE. Do you see any
> reason to use a different bit for it?

As for the flags, VXLAN-GBP, VXLAN-GPE and VXLAN-RCO are compatible
with each other. It's not possible to use GBP and GPE together because
the group policy id and the next protocol field are overlapping but
it's possible to distinguish whether it's GBP or GPE based on the
flags.

There should be no problem using GPE and RCO together (at least now,
when this patch is applied). It needs to be explicitly configured as
such when creating the interface, though.

 Jiri

-- 
Jiri Benc
