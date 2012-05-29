From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls (after
 pci_enable_device) fails
Date: Wed, 30 May 2012 04:49:18 +0530
Message-ID: <CAHdPZaMcfwAk3toTvCwh31T5BQMeHJVP-sHwd9kL5rvFOG6N8A@mail.gmail.com>
References: <1338206223-26781-1-git-send-email-devendra.aaru@gmail.com>
	<1659482.3g1Zl6FDuM@flexo>
	<20120529.172229.277102319861990758.davem@davemloft.net>
	<20120529.172843.1775456038320356018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57039 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab2E2XTS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 19:19:18 -0400
In-Reply-To: <20120529.172843.1775456038320356018.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, May 30, 2012 at 2:58 AM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 29 May 2012 17:22:29 -0400 (EDT)
>
> Actually, reverted, you didn't test this patch at all.
>
> You didn't even look at the warnings emitted by the compiler
> with your changes installed.
>
> You're passing a network device pointer into the PCI device
> disable routine, which takes a PCI device pointer.
>
> I can't express to you how extremely irritating it is when
> people submit patches like this.
>
> The bug in question is 1,000 times less harmful than your fix.

Sorry about that, i agree that i didn't even tested it as i dont have
r6040 network adapter here, but i didn't even compiled it.

i sent the patch again to fix this problem.

Sorry,
Devendra.
