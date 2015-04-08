From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 3/3] e1000, e1000e: Use dma_rmb instead of rmb
 for descriptor read ordering
Date: Tue, 7 Apr 2015 18:06:20 -0700
Message-ID: <CAL3LdT7vKH+_6rn+p7fgZgLzq8wKTWBN6QRxKwpjMVOpXD=euw@mail.gmail.com>
References: <20150407235324.1574.63255.stgit@ahduyck-vm-fedora22>
	<20150407235527.1574.69801.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33496 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622AbbDHBGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 21:06:21 -0400
Received: by oblw8 with SMTP id w8so66855978obl.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 18:06:20 -0700 (PDT)
In-Reply-To: <20150407235527.1574.69801.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 7, 2015 at 4:55 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> This change replaces calls to rmb with dma_rmb in the case where we want to
> order all follow-on descriptor reads after the check for the descriptor
> status bit.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |    6 +++---
>  drivers/net/ethernet/intel/e1000e/netdev.c    |    8 ++++----
>  2 files changed, 7 insertions(+), 7 deletions(-)
