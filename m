From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 v3 00/12] net-caif: introducing CAIF
 protocol stack
Date: Tue, 23 Feb 2010 08:33:07 +0100
Message-ID: <1266910387.18491.54.camel@violet>
References: <1266876331-23988-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:34117 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804Ab0BWHbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 02:31:42 -0500
In-Reply-To: <1266876331-23988-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> This patch-set introduces the CAIF protocol Stack.
> The "Communication CPU to Application CPU Interface" (CAIF) is a packet based
> connection-oriented MUX protocol developed by ST-Ericsson for use with its
> modems.
> 
> 
> CHANGE LOG:
> Based on review comments from David Miller and Marcel Holtmann on the 
> previous patch set submitted the 16 February the following changes
> have been done:
> - Removed ifdef __cplusplus from caif_socket.h
> - Use socket level SOL_IP for socket options SO_PRIORITY and SO_BINDTODEVICE

are you sure it is not better to use SOL_SOCKET here. At least according
to man 7 socket this would make a lot more sense. My point in actually
using SO_PRIORITY and SO_BINDTODEVICE is to use standard socket options
that are already used by everybody else. So they know what to expect.

Regards

Marcel


