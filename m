From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Thu, 15 Jan 2015 17:56:02 -0800
Message-ID: <20150115175602.0709cb45@urahara>
References: <y>
	<1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, grant.likely@linaro.org, robh+dt@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stephen Wang <wstephen@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:62942 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbbAPB4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 20:56:14 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so21041731pac.11
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 17:56:14 -0800 (PST)
In-Reply-To: <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Jan 2015 14:03:46 -0800
Stephen Wang <wstephen@codeaurora.org> wrote:

> +	uint32_t rx_bytes;		/**< Number of RX bytes */
> +	uint32_t rx_packets;		/**< Number of RX packets */

32 bit packet stats are a problem with lots of traffic.
