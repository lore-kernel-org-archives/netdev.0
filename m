From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 6 Nov 2008 17:56:45 +0100
Message-ID: <200811061756.45493.mb@bu3sch.de>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org> <1225969620.3619.204.camel@johannes.berg> <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:37149 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbYKFQ5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 11:57:20 -0500
In-Reply-To: <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 November 2008 12:15:24 Mike Frysinger wrote:
> linux/ssb/ssb.h always calls pci_dma_* functions

No it doesn't. Read the code.
pci_dma_xxx functions should probably declared to no-op inlines in
the pci.h header.
However, we can also ifdef them in ssb.h.

-- 
Greetings Michael.
