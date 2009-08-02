From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/9] return PCI_ERS_RESULT_DISCONNECT on
 permanent failure
Date: Sat, 01 Aug 2009 23:13:29 -0700 (PDT)
Message-ID: <20090801.231329.53805783.davem@davemloft.net>
References: <20090731191254.5470.99642.send-patch@aqua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dnelson@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35063
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751183AbZHBGNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:13:21 -0400
In-Reply-To: <20090731191254.5470.99642.send-patch@aqua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dean Nelson <dnelson@redhat.com>
Date: Fri, 31 Jul 2009 15:12:55 -0400

> PCI drivers that implement the struct pci_error_handlers' error_detected
> callback should return PCI_ERS_RESULT_DISCONNECT if the state passed in is
> pci_channel_io_perm_failure.
 ...
> This patchset is an attempt to address the remaining net drivers of this type.
> None of the patches in this patchset have been tested, since I don't have the
> hardware to test any of them. I'm simply making these patches available for
> whomever is interested and able to test them, to do so. Perhaps the individual
> patches can be committed as they get tested, reviewed and ACK'd.

I think these are safe to apply, they look so straightforward
to me.  I've thus added them all to net-next-2.6, thanks!
