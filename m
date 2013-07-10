From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: [GIT] Networking
Date: Wed, 10 Jul 2013 08:43:50 -0400
Message-ID: <CA+5PVA5AT0OLNi-=x91ks5AbigymE3BDmdoEiiNOeRoGFCFQfg@mail.gmail.com>
References: <20130709.145325.1363244885668360965.davem@davemloft.net>
	<20130710122523.GA357@x4>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	Alexey Brodkin <Alexey.Brodkin@synopsys.com>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:41519 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345Ab3GJMnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 08:43:51 -0400
In-Reply-To: <20130710122523.GA357@x4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 8:25 AM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
> On 2013.07.09 at 14:53 -0700, David Miller wrote:
>>
>> Alexey Brodkin (2):
>>       ethernet/arc/arc_emac - Add new driver
>>       arc_emac: fix compile-time errors & warnings on PPC64
>
> This driver defaults to y for no reason:
>
> +config NET_VENDOR_ARC
> +       bool "ARC devices"
> +       default y

That's the option to enable the ARC vendor, not the driver.  The
driver config option is ARC_EMAC.  All of the other ethernet vendors
also default to y, so I don't think this is out of line.

josh
