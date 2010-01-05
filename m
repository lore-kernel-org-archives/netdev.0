From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH NEXT 0/2] qlcnic: Add Qlogic 1/10Gb Ethernet driver for
 CNA devices
Date: Tue, 5 Jan 2010 09:07:17 -0800
Message-ID: <20100105090717.15d532ce@nehalam>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39821 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752Ab0AERHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 12:07:24 -0500
In-Reply-To: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jan 2010 05:24:34 -0800
Amit Kumar Salecha <amit.salecha@qlogic.com> wrote:

> Hi
>   Series of 2 patches to add Qlogic ethernet driver for QLE8240 and
>   QLE8242 CNA devices. QLE8240 and QLE8242 devices support various 
>   class of drivers.
>   Please apply to net-next tree.
> 
> -Amit Salecha
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The patches are out of order. If patch 1 was applied (but not patch 2),
then it would be possible to configure device but the actual driver
code would not be there. This could happen when doing git bisect.

I assume Dave will just resolve this by combining the two before
merging.

-- 
