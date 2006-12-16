From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3] chelsio: more receive cleanup
Date: Sat, 16 Dec 2006 01:26:04 +0100
Message-ID: <20061216002604.GA11284@electric-eye.fr.zoreil.com>
References: <20061215190716.956791000@osdl.org> <20061215190813.803776000@osdl.org> <20061215201019.GA11385@electric-eye.fr.zoreil.com> <20061215145533.4cda3f23@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37791 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030480AbWLPA3U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 19:29:20 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061215145533.4cda3f23@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> Francois Romieu <romieu@fr.zoreil.com> wrote:
[...]
> Why, you can't predict copybreak on off

Plain gut feeling. I'd rather spend extra cycles on small packets (whose
allocation is already optimized) and keep the normal packets less expensive
on a 10Gb/s network card.

[...]
> This is wrong, NET_IP_ALIGN is for DMA buffers only. It is defined
> as 0 for those platforms where DMA alignment is important. In this
> case we are copying, so we want to force 2.

Ok, ok.

-- 
Ueimor
