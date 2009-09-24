From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: pktgen: tricks
Date: Thu, 24 Sep 2009 13:10:05 +0300
Message-ID: <200909241310.05297.denys@visp.net.lb>
References: <20090922224902.17ed6cc4@nehalam> <20090923174141.1d350103@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44367 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbZIXKGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 06:06:42 -0400
In-Reply-To: <20090923174141.1d350103@s6510>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 September 2009 03:41:41 Stephen Hemminger wrote:
> Other kernel config help:
>   - turn off lock dependency checker, kmecheck, page alloc debug
>     basically anything that slows stuff down
>   - turn off content group scheduler
Maybe, but i'm not sure (i can't test it):
Disable randomize VA space? On embedded boards it was helping. 
In some case disabling SMP helped, when various SMP locks involved, but maybe 
not for pktgen.


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


