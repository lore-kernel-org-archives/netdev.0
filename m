From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 001/001] smsc95xx: Fix hard_header_len
Date: Fri, 17 Aug 2012 09:35:04 +0100
Message-ID: <CAKh2mn6fr8WjT-2h_A3zmKv3xs26AamXcpJgtK5wFPQ1BXuheg@mail.gmail.com>
References: <1345060138-5629-1-git-send-email-jimbob.betts@googlemail.com>
	<CAKh2mn4pK-8=OVkahSZ8VWpX9Va=qCDQUdOONK1FZ75Fbk0Mdg@mail.gmail.com>
	<1345139973.2832.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: JamesBetts <jimbob.betts@googlemail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:50751 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933694Ab2HQIfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2012 04:35:05 -0400
Received: by obbuo13 with SMTP id uo13so4967348obb.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 01:35:04 -0700 (PDT)
In-Reply-To: <1345139973.2832.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> hard_header_len is set to ETH_HLEN by alloc_etherdev() (in the
> ether_setup() callback).  Any extra headroom you want before the
> Ethernet header should indeed be specified in needed_headroom.

Thanks Ben, looks like this patch is doing it the right way then.

Acked-By: Steve Glendinning <steve.glendinning@shawell.net>


-- 
Steve Glendinning
