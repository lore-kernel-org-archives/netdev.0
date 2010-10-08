From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Add Qualcomm Gobi 2000 driver.
Date: Fri, 08 Oct 2010 10:28:03 -0700 (PDT)
Message-ID: <20101008.102803.104075511.davem@davemloft.net>
References: <20101006151208.GB1571@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jglasgow@google.com, mjg59@srcf.ucam.org,
	msb@google.com, olofj@google.com
To: ellyjones@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39392
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758943Ab0JHR1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:27:41 -0400
In-Reply-To: <20101006151208.GB1571@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elly Jones <ellyjones@google.com>
Date: Wed, 6 Oct 2010 11:12:09 -0400

> From: Elizabeth Jones <ellyjones@google.com>
> 
> This driver is a rewrite of the original Qualcomm GPL driver, released as part
> of Qualcomm's "Code Aurora" initiative. The driver has been transformed into
> Linux kernel style and made to use kernel APIs where appropriate; some bugs have
> also been fixed. Note that the device in question requires firmware and a
> firmware loader; the latter has been written by mjg (see
> http://www.codon.org.uk/~mjg59/gobi_loader/).
> 
> Special thanks go to Joe Perches <joe@perches.com> for major cleanup.
> 
> Signed-off-by: Elizabeth Jones <ellyjones@google.com>
> Signed-off-by: Jason Glasgow <jglasgow@google.com>

I really think the firmware handling belongs in the kernel.

I've looked at the gobi_loader code and it's simpler than many
of the gigabit ethernet driver firmware loader sequences in
the tree already.

Requiring udev et al. magic only makes this networking device
that much harder to use from an initrd.

I understand how this might be a bit clumsy since we'd need to make a
dependency on the serial device since that is the mechanism by which
the firmware is uploaded, but really I'd like you to consider it
seriously.
