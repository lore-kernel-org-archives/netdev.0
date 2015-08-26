From: Jeremy Harris <jgh@redhat.com>
Subject: Re: [PATCH] man ip-link: Add more explanation about vlan reordering
Date: Wed, 26 Aug 2015 16:27:48 +0100
Message-ID: <55DDDAF4.30904@redhat.com>
References: <1439839344-12772-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751697AbbHZP1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 11:27:51 -0400
In-Reply-To: <1439839344-12772-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/08/15 20:22, Vadim Kochan wrote:
> +.BR reorder_hdr " is " on
> +then VLAN header will be not inserted immediately but only before passing to the
> +physical device (if this device does not support VLAN offloading), the similar
> +on the RX direction - by default the packet will be untagged before being
> +received by VLAN device. Reordering allows to accelerate tagging on egress and
> +to hide VLAN header on ingress so the packet looks like regular Ethernet packet,
> +at the same time it might be confusing while the packet sniffing as the VLAN header
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^

Does not read well.  "for packet capture" perhaps?
-- 
Jeremy
