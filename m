From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: Extend trust to allow guest to set
 unicast address
Date: Thu, 31 Dec 2015 16:03:29 -0800
Message-ID: <CAL3LdT6OZ0F4oH1geii8K73EBGahNhhtbfYOW4d1RFUYaaO2Fw@mail.gmail.com>
References: <1451560331-21378-1-git-send-email-3chas3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33848 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcAAADa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 19:03:30 -0500
Received: by mail-io0-f177.google.com with SMTP id 1so56429593ion.1
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2015 16:03:29 -0800 (PST)
In-Reply-To: <1451560331-21378-1-git-send-email-3chas3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 31, 2015 at 3:12 AM, Chas Williams <3chas3@gmail.com> wrote:
> When running certain routing protocols like VRRP, VF guests need the
> ability to set the unicast address of the interface.  Extend the new ndo
> trust feature to let the hypervisor trust a guest to set/update its own
> unicast address.
>
> Signed-off-by: Chas Williams <3chas3@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Please send this to intel-wired-lan@lists.osuosl.org mailing list, or
at least CC the list since all Wired Ethernet Intel driver patches are
handled through that list.
