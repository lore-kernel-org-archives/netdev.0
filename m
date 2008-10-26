From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/1] r8169: revert "read MAC address from EEPROM on init"
Date: Sun, 26 Oct 2008 12:26:27 -0400
Message-ID: <49049A33.2080203@pobox.com>
References: <20081026160249.GA25443@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alistair John Strachan <alistair@devzero.co.uk>,
	Ivan Vecera <ivecera@redhat.com>,
	Chuck Ebbert <cebbert@redhat.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall=F3n=22?= <jamagallon@ono.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Simon Arlott <simon@fire.lp0.eu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57326 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751162AbYJZQ1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 12:27:21 -0400
In-Reply-To: <20081026160249.GA25443@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> This reverts commit 7bf6bf4803df1adc927f585168d2135fb019c698.
> 
> The code has both a short existence and an increasing track
> of failures despite some work to amend it for -rc1. It is not
> just a matter of reading the eeprom: sometimes the eeprom is
> read correctly, then the mac address is not written correctly
> back into the mac registers.
> 
> Some chipsets seem to work reliably but it is not clear at
> this point if the code can simply be made to work on a
> per-chipset basis and post -rc1 is not the place where I want
> to experiment these things.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Acked-by: Jeff Garzik <jgarzik@redhat.com>

I'll send upstream if Linus doesn't pick it up shortly...


