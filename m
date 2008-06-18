From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] [UPDATED] ixgbe: add LRO support
Date: Wed, 18 Jun 2008 15:32:00 -0700
Message-ID: <9929d2390806181532ub067a64y74b6315f1bd68375@mail.gmail.com>
References: <20080613183716.9641.33945.stgit@localhost.localdomain>
	 <48588933.2060605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, randy.dunlap@oracle.com
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:31777 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754204AbYFRWcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 18:32:00 -0400
Received: by wa-out-1112.google.com with SMTP id j37so342577waf.23
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 15:32:00 -0700 (PDT)
In-Reply-To: <48588933.2060605@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 9:04 PM, Jeff Garzik <jeff@garzik.org> wrote:
>
> I take that back.
>
> This patch has a bunch of checkpatch problems, and it doesn't even compile,
> so it obviously was not tested:
>
> drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_receive_skb':
> drivers/net/ixgbe/ixgbe_main.c:416: error: implicit declaration of function
> 'vlan_nw_accel_receive_skb'
>
> --

My apologies, in the last update, the patch got altered in my tree.  I
will re-send the corrected patch which has been tested.

-- 
Cheers,
Jeff
