From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 23 Nov 2009 20:27:24 -0800
Message-ID: <20091123202724.0b0a399d@s6510>
References: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57253 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757990AbZKXE1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 23:27:35 -0500
In-Reply-To: <200911240351.nAO3p1AY025627@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009 19:51:01 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> 	cmd.rxf_id_mask[0] = htonl((u32) rxf_id_mask);
> +	cmd.rxf_id_mask[1] = htonl((u32) (rxf_id_mask >> 32));

You could use the lower32() and upper32() macros here.
