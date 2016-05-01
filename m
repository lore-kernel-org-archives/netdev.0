From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 5/9] mlx4: Add support for UDP tunnel
 segmentation with outer checksum offload
Date: Sun, 1 May 2016 23:35:04 +0300
Message-ID: <CAJ3xEMiog9zEwg_S=jG5LjM6FpvtyffvPcYX_G4j-ubBE_wLDw@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
	<20160429224333.12418.13862.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	michael.chan@broadcom.com, David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36425 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbcEAUfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:35:05 -0400
Received: by mail-io0-f171.google.com with SMTP id u185so178478180iod.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:35:05 -0700 (PDT)
In-Reply-To: <20160429224333.12418.13862.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch assumes that the mlx4 hardware will ignore existing IPv4/v6
> header fields for length and checksum as well as the length and checksum
> fields for outer UDP headers.

Hi Alex,

I see now the above text appearing in bunch of similar commit of
yours, specifically to Intel drivers and mlx5... could you please
elaborate a bit more what you mean here and what are the practical
consequences of that characteristics?

I got that right NETIF_F_GSO_UDP_TUNNEL_CSUM means that the HW can do
segmentation for TCP packets encapsulated by UDP tunnel e.g VXLAN
where the outer checksum is not zero. AFAIK, any other outer checksum
value can't correctly be a constant... are you assuming here  RCO or
LCO?

Or.
