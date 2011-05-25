From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: isdn: netjet - blacklist Digium TDM400P
Date: Wed, 25 May 2011 17:57:35 -0400 (EDT)
Message-ID: <20110525.175735.477785089681085806.davem@davemloft.net>
References: <20110525121223.26439.57412.sendpatchset@prarit.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: prarit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932362Ab1EYV5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:57:44 -0400
In-Reply-To: <20110525121223.26439.57412.sendpatchset@prarit.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 25 May 2011 08:12:23 -0400

> [2nd try ... 1st attempt didn't make it to netdev mailing list]
> 
> A quick google search reveals that people with this card are blacklisting it
> in the initramfs and in the module blacklist based on a statement that it
> is unsupported. Since the older Digium is also unsupported I'm pretty
> confident that this newer card is also not supported.
> 
> lspci -xxx -vv shows
> 
> 04:07.0 Communication controller: Tiger Jet Network Inc. Tiger3XX Modem/ISDN interface
>         Subsystem: Device b100:0003
> P.
> 
> ----8<----
> The Asterisk Voice Card, DIGIUM TDM400P is unsupported by the netjet driver.
> Blacklist it like the Digium X100P/X101P card.
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>

Applied.
