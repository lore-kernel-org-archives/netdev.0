From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v5 00/12] net-caif: introducing CAIF
 protocol stack
Date: Sun, 28 Feb 2010 18:22:53 -0800 (PST)
Message-ID: <20100228.182253.35341423.davem@davemloft.net>
References: <1267409378-2082-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, kaber@trash.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751990Ab0CACWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 21:22:36 -0500
In-Reply-To: <1267409378-2082-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We don't use "u_int8_t" et al. types in the kernel, even in headers
that define user interfaces.  Use "u8", "u16", et al. instead.

Please fix this up and resubmit your patch series.
