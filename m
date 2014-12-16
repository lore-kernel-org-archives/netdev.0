From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Tue, 16 Dec 2014 10:56:27 -0800
Message-ID: <CAL3LdT4dTujZ7f3pd-BqE9HLDeBoAfr7TcZb_WnKqZM-Gs2YOA@mail.gmail.com>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
	gospo@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:59279 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaLPS41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 13:56:27 -0500
Received: by mail-ob0-f181.google.com with SMTP id gq1so24436509obb.12
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 10:56:27 -0800 (PST)
In-Reply-To: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2014 at 8:19 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> The current implementations all use dev_uc_add_excl() and such whose API
> doesn't support vlans, so we can't make it with NICs HW for now.
>
> Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c |    5 +++++
>  net/core/rtnetlink.c                        |    5 +++++
>  2 files changed, 10 insertions(+), 0 deletions(-)
>

For the Intel driver changes...
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
