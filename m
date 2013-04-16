From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 0/2 v3] changed irq handling for
 at86rf230
Date: Mon, 15 Apr 2013 22:44:19 -0300
Message-ID: <20130416014419.GF29789@ws>
References: <cover.1366012862.git.sascha@ps.nvbi.de>
 <20130415.154931.1534207963525784709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sascha@ps.nvbi.de, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:49428 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934863Ab3DPBp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 21:45:59 -0400
Content-Disposition: inline
In-Reply-To: <20130415.154931.1534207963525784709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I'd like to see some reviews of this patch series, thanks.

Sascha and I discussed the functional aspects of his changes a
while ago and I'm satisfied with the way he has done things now.
I also believe his approach to be technically sound.

Furthermore, I merged his changes into my atben driver (which
uses level-triggered interrupts while Sascha's platform is
edge-triggered), and it passed some light testing.

- Werner
