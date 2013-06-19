From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 07/11] sfc: Do not pass non-TCP packets into
 GRO code
Date: Wed, 19 Jun 2013 15:56:28 -0700
Message-ID: <1371682588.3252.354.camel@edumazet-glaptop>
References: <1371680169.1956.107.camel@bwh-desktop.uk.level5networks.com>
	 <1371680396.1956.114.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:49074 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935028Ab3FSW4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 18:56:33 -0400
Received: by mail-ea0-f170.google.com with SMTP id h10so3541130eaj.15
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 15:56:32 -0700 (PDT)
In-Reply-To: <1371680396.1956.114.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 23:19 +0100, Ben Hutchings wrote:
> GRO can handle non-TCP packets and pass them up without coalescing,
> but it has to do some extra work to parse the packet which we can
> bypass using the hardware parse result.  (Falcon won't mark TCP/IPv6
> packets as TCP, but then it won't validate their checksums either, so
> GRO can't coalesce them.)

Thats not exactly true. GRO can validate the checksums.
