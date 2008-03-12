From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Re: WAN: new PPP code for generic HDLC
Date: Wed, 12 Mar 2008 11:52:15 -0700
Message-ID: <20080312115215.5fb1a370@extreme>
References: <m3prtzsszg.fsf@maximus.localdomain>
	<m3lk4nsskh.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57073 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbYCLSwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2008 14:52:22 -0400
In-Reply-To: <m3lk4nsskh.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +struct hdlc_header {
> +	u8 address;
> +	u8 control;
> +	__be16 protocol;
> +} __attribute__ ((packed));
> +
> +struct cp_header {
> +	u8 code;
> +	u8 id;
> +	__be16 len;
> +} __attribute__ ((packed));
> +

If I remember correctly, the packed is unnecessary for structures like this
and causes GCC to generate worse code.
