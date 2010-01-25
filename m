From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1 V4] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC
 driver
Date: Mon, 25 Jan 2010 08:31:31 -0800
Message-ID: <20100125083131.568abc34@nehalam>
References: <1264417272-3800-1-git-send-email-kristoffer@gaisler.com>
	<1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33932 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632Ab0AYQbm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 11:31:42 -0500
In-Reply-To: <1264417272-3800-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010 12:01:12 +0100
Kristoffer Glembo <kristoffer@gaisler.com> wrote:

> +/* Accept MAC address of the form macaddr=0x08,0x00,0x20,0x30,0x40,0x50 */
> +static int macaddr[6];
> +module_param_array(macaddr, int, NULL, 0);
> +MODULE_PARM_DESC(macaddr, "GRETH Ethernet MAC address");

Don't you want an array of uchar here not int?

-- 
