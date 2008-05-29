From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] 8139too: Make PIO/MMIO a modparam
Date: Thu, 29 May 2008 14:18:45 -0400
Message-ID: <483EF385.3000103@garzik.org>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org> <20080529150752.GB8247@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37617 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754352AbYE2STR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 14:19:17 -0400
In-Reply-To: <20080529150752.GB8247@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones wrote:
> Make PIO/MMIO a runtime thing via a module parameter.
> This is needed to support devices that only work with PIO
> without penalising devices that work fine with MMIO in
> distro kernels.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

two comments:

1) should use pci_iomap() for both PIO and MMIO

2) modparam should be "use_io" mirroring existing drivers


