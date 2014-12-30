From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] tunnel: support propagating lower device state
Date: Tue, 30 Dec 2014 12:37:30 -0800
Message-ID: <CAHA+R7OjUX43QjZbTvZ8CtoDB4uJxJc8f-KvU8a3EB2K5CZF7w@mail.gmail.com>
References: <20141227095950.20a062d2@urahara>
	<CAHA+R7OTFAc=1D=WRxLNuqScBJ+wD-wc-qxtNaFxSji_kRi1PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:60830 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaL3Uhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 15:37:31 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so10818867qcx.40
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 12:37:30 -0800 (PST)
In-Reply-To: <CAHA+R7OTFAc=1D=WRxLNuqScBJ+wD-wc-qxtNaFxSji_kRi1PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 12:33 PM, Cong Wang <cwang@twopensource.com> wrote:
>
> Are you sure we really need to free itn->tunnels on
> failure path? It is not allocated inside ip_tunnel_init_net()
> anyway.

Also you seem to forget to kfree() itn->lower_dev in
ip_tunnel_delete_net().
