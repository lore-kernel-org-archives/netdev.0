From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH V3 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 15:29:30 -0700
Message-ID: <CAKgT0Ue7HL4CWdF2jBzLYOqXuO2=J9GeF79qfcdOWB7+cA0_3Q@mail.gmail.com>
References: <cover.1476737917.git.sowmini.varadhan@oracle.com> <07bf787b2a346e12ca6e57edaf1a3025de9ae5dc.1476737917.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33552 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754883AbcJQW3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 18:29:31 -0400
Received: by mail-io0-f194.google.com with SMTP id q192so11683707iod.0
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 15:29:31 -0700 (PDT)
In-Reply-To: <07bf787b2a346e12ca6e57edaf1a3025de9ae5dc.1476737917.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 2:12 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> For some Tx paths (e.g., tpacket_snd()), ixgbe_atr may be
> passed down an sk_buff that has the network and transport
> header in the paged data, so it needs to make sure these
> headers are available in the headlen bytes to calculate the
> l4_proto.
>
> This patch expect that network and transport headers are
> already available in the non-paged header dat.  The assumption
> is that the caller has set this up if l4_proto based Tx
> steering is desired.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

This all looks correct to me.  I would recommend having Jeff pull it
in to be submitted to the net queue.

Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>
