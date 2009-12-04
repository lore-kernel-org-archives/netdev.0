From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: allow tx of pre-formatted vlan tagged packets
Date: Fri, 4 Dec 2009 13:45:44 -0800
Message-ID: <9929d2390912041345g4557770bh1467db58b8ade572@mail.gmail.com>
References: <1259961156.4198.163.camel@gshetty>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arthur Jones <ajones@riverbed.com>
To: Gurucharan Shetty <gshetty@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:61197 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757298AbZLDVph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 16:45:37 -0500
Received: by pwi3 with SMTP id 3so2360365pwi.21
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2009 13:45:44 -0800 (PST)
In-Reply-To: <1259961156.4198.163.camel@gshetty>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2009 at 13:12, Gurucharan Shetty <gshetty@riverbed.com> wrote:
> ixgbe: allow tx of pre-formatted vlan tagged packets
>
> When the 82598 is fed 802.1q packets, it chokes with
> an error of the form:
>
> ixgbe: eth0: ixgbe_tx_csum: partial checksum but proto=81!
>
> As the logic there was not smart enough to look into
> the vlan header to pick out the encapsulated protocol.
>
> There are times when we'd like to send these packets
> out without having to configure a vlan on the interface.
> Here we check for the vlan tag and allow the packet to
> go out with the correct hardware checksum.
>
> This patch is a clone of a previously submitted patch by
> Arthur Jones <ajones@riverbed.com> for igb (Commit -
> fa4a7ef36ec834fee1719636b30d2f28f4cb0166).
>
> Signed-off-by: Gurucharan Shetty <gshetty@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
>

Thanks, I have added the patch to my queue for testing.  After
successful testing, I will push to Dave/netdev.

-- 
Cheers,
Jeff
