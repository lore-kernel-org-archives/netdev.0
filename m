From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v2 4/5] fm10k/igb/ixgbe: Replace __skb_alloc_page
 with netdev_alloc_page
Date: Tue, 11 Nov 2014 09:15:14 -0800
Message-ID: <CAHA+R7P+GtA6xHxrPZOhxHM0LA8mGkmWugTqLeHtw5M6P3udvQ@mail.gmail.com>
References: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
	<20141111171117.15976.41609.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de,
	David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:38701 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaKKRPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 12:15:15 -0500
Received: by mail-qg0-f41.google.com with SMTP id q107so7569268qgd.0
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 09:15:15 -0800 (PST)
In-Reply-To: <20141111171117.15976.41609.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 11, 2014 at 9:11 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> index e645af4..73457ed 100644
> --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
> @@ -83,7 +83,7 @@ static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
>                 return true;
>
>         /* alloc new page for storage */
> -       page = alloc_page(GFP_ATOMIC | __GFP_COLD);
> +       page = dev_alloc_page();

Doesn't match $subject.
