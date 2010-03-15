From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 v6 08/12] net-caif: add CAIF socket
 implementation
Date: Mon, 15 Mar 2010 14:53:51 -0700
Message-ID: <1268690031.2700.9.camel@localhost.localdomain>
References: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-2-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-3-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-4-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-5-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-6-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-7-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-8-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-9-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43312 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936880Ab0COVzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 17:55:52 -0400
In-Reply-To: <1267445559-1911-9-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> +	/*
> +	 * The sock->type specifies the socket type to use. The CAIF socket is
> +	 * a packet stream in the sence that it is packet based.
> +	 * CAIF trusts the reliability of the link, no resending is implemented.
> +	 */
> +	if (sock->type != SOCK_SEQPACKET)
> +		return -ESOCKTNOSUPPORT;

we came to an interesting detail here when testing with a STE modem. Why
is this SEQPACKET and not a STREAM. Especially with the AT command
channels it is kinda weird that you have an MTU. The AT specification
doesn't really have any defined behavior when using a sequential packet
transport. It is more a stream based socket.

Regards

Marcel


